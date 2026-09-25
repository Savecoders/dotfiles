import QtQuick
import Quickshell
import Quickshell.Bluetooth as QsBluetooth
import Quickshell.Io
import qs.core
import qs.features
pragma Singleton

Singleton {
    id: root

    property bool bluetoothEnabled: false
    property bool isScanning: false
    property bool isConnecting: false
    property bool isPairing: false
    property string connectingAddress: ""
    property string pairingAddress: ""
    property string errorMessage: ""
    property string activeDeviceName: ""
    property int connectedCount: 0
    property var devices: []

    // Helper: Material icon based on device type or name
    function getDeviceIcon(rawIcon, name) {
        let combined = ((rawIcon || "") + " " + (name || "")).toLowerCase();
        if (combined.includes("headphone") || combined.includes("headset") || combined.includes("airpod") || combined.includes("buds"))
            return "headphones";

        if (combined.includes("audio") || combined.includes("sound") || combined.includes("speaker") || combined.includes("sbw") || combined.includes("hifi") || combined.includes("bar"))
            return "speaker";

        if (combined.includes("phone") || combined.includes("iphone") || combined.includes("android") || combined.includes("pixel"))
            return "smartphone";

        if (combined.includes("computer") || combined.includes("laptop") || combined.includes("pc") || combined.includes("macbook"))
            return "laptop";

        if (combined.includes("mouse"))
            return "mouse";

        if (combined.includes("keyboard") || combined.includes("keychron"))
            return "keyboard";

        if (combined.includes("controller") || combined.includes("gamepad") || combined.includes("joystick"))
            return "sports_esports";

        if (combined.includes("watch") || combined.includes("band"))
            return "watch";

        return "bluetooth";
    }

    // Refresh devices from native Quickshell Bluetooth adapter and bluetoothctl
    function refreshDevices() {
        const adapter = QsBluetooth.Bluetooth.defaultAdapter;
        if (!adapter || adapter.state <= QsBluetooth.BluetoothAdapterState.Disabled) {
            root.bluetoothEnabled = false;
            root.activeDeviceName = "";
            root.connectedCount = 0;
            root.devices = [];
            return ;
        }
        root.bluetoothEnabled = (adapter.state === QsBluetooth.BluetoothAdapterState.Enabled);
        const rawDevices = (adapter.devices && adapter.devices.values) ? adapter.devices.values : [];
        let list = [];
        let connectedFound = [];
        for (let i = 0; i < rawDevices.length; i++) {
            let d = rawDevices[i];
            if (!d)
                continue;

            let addr = d.address || "";
            let dName = d.name || d.deviceName || addr;
            if (!dName || dName.trim() === "")
                continue;

            let isConn = !!d.connected;
            let isPrd = !!d.paired || !!d.bonded;
            let isPrng = !!d.pairing || (root.isPairing && root.pairingAddress === addr);
            let batt = -1;
            if (d.batteryAvailable)
                batt = Math.round(d.battery <= 1 ? d.battery * 100 : d.battery);

            if (isConn)
                connectedFound.push(dName);

            list.push({
                "address": addr,
                "name": dName,
                "icon": root.getDeviceIcon(d.icon, dName),
                "isConnected": isConn,
                "isPaired": isPrd,
                "isPairing": isPrng,
                "isTrusted": !!d.trusted,
                "batteryAvailable": !!d.batteryAvailable,
                "battery": batt
            });
        }
        root.connectedCount = connectedFound.length;
        if (connectedFound.length === 1)
            root.activeDeviceName = connectedFound[0];
        else if (connectedFound.length > 1)
            root.activeDeviceName = `${connectedFound.length} Connected`;
        else
            root.activeDeviceName = "";
        // Sort: Connected first, then Paired, then Available, sorted alphabetically
        list.sort((a, b) => {
            if (a.isConnected !== b.isConnected)
                return a.isConnected ? -1 : 1;

            if (a.isPaired !== b.isPaired)
                return a.isPaired ? -1 : 1;

            return a.name.localeCompare(b.name);
        });
        root.devices = list;
    }

    // Start scanning for Bluetooth devices
    function scan(explicitRescan) {
        const adapter = QsBluetooth.Bluetooth.defaultAdapter;
        if (adapter) {
            try {
                adapter.discovering = true;
            } catch (e) {
            }
        }
        if (scanProc.running) {
            if (explicitRescan)
                scanProc.running = false;
            else
                return ;
        }
        root.isScanning = true;
        scanProc.command = ["bluetoothctl", "--timeout", "15", "scan", "on"];
        scanProc.running = true;
    }

    // Stop scanning
    function stopScan() {
        const adapter = QsBluetooth.Bluetooth.defaultAdapter;
        if (adapter) {
            try {
                adapter.discovering = false;
            } catch (e) {
            }
        }
        if (scanProc.running)
            scanProc.running = false;

        root.isScanning = false;
    }

    // Toggle Bluetooth power on/off
    function toggleBluetooth() {
        const adapter = QsBluetooth.Bluetooth.defaultAdapter;
        const willEnable = !root.bluetoothEnabled;
        root.errorMessage = "";
        if (willEnable) {
            rfkillUnblock.running = true;
        } else {
            if (adapter) {
                try {
                    adapter.enabled = false;
                } catch (e) {
                }
            }
            Quickshell.execDetached(["bluetoothctl", "power", "off"]);
            root.bluetoothEnabled = false;
            root.isScanning = false;
            root.devices = [];
        }
        refreshTimer.restart();
    }

    // Connect to a device by MAC address
    function connectDevice(address) {
        if (!address || address === "" || root.isConnecting)
            return ;

        root.isConnecting = true;
        root.connectingAddress = address;
        root.errorMessage = "";
        connectProc.command = ["bluetoothctl", "connect", address];
        connectProc.running = true;
    }

    // Disconnect device by MAC address
    function disconnectDevice(address) {
        if (!address || address === "")
            return ;

        root.errorMessage = "";
        disconnectProc.command = ["bluetoothctl", "disconnect", address];
        disconnectProc.running = true;
    }

    // Pair with a device (and trust it)
    function pairDevice(address) {
        if (!address || address === "" || root.isPairing)
            return ;

        root.isPairing = true;
        root.pairingAddress = address;
        root.errorMessage = "";
        let cmd = "bluetoothctl pair " + address + " && bluetoothctl trust " + address + " && bluetoothctl connect " + address;
        pairProc.command = ["sh", "-c", cmd];
        pairProc.running = true;
    }

    // Forget / Unpair a device
    function forgetDevice(address) {
        if (!address || address === "")
            return ;

        root.errorMessage = "";
        forgetProc.command = ["bluetoothctl", "remove", address];
        forgetProc.running = true;
    }

    Component.onCompleted: {
        Qt.callLater(() => {
            root.refreshDevices();
        });
    }

    // Rfkill unblock process
    Process {
        id: rfkillUnblock

        command: ["rfkill", "unblock", "bluetooth"]
        onExited: {
            Quickshell.execDetached(["bluetoothctl", "power", "on"]);
            Qt.callLater(() => {
                const adapter = QsBluetooth.Bluetooth.defaultAdapter;
                if (adapter && adapter.state !== QsBluetooth.BluetoothAdapterState.Enabled) {
                    try {
                        adapter.enabled = true;
                    } catch (e) {
                    }
                }
                root.refreshDevices();
                root.scan(false);
            });
        }
    }

    // Scan process
    Process {
        id: scanProc

        onRunningChanged: {
            if (!running) {
                root.isScanning = false;
                Qt.callLater(() => {
                    root.refreshDevices();
                });
            }
        }
    }

    // Connect process
    Process {
        id: connectProc

        property string errorBuf: ""

        onRunningChanged: {
            if (running) {
                errorBuf = "";
                return ;
            }
            root.isConnecting = false;
            let targetAddr = root.connectingAddress;
            root.connectingAddress = "";
            let err = errorBuf.trim();
            errorBuf = "";
            if (exitCode !== 0) {
                if (err.includes("Failed to connect") || err.includes("not available"))
                    root.errorMessage = "Device not available or refused connection";
                else if (err.length > 0)
                    root.errorMessage = err.split("\n")[0].replace("Failed to connect: ", "");
                else
                    root.errorMessage = "Connection failed to " + targetAddr;
            } else {
                root.errorMessage = "";
            }
            Qt.callLater(() => {
                root.refreshDevices();
            });
        }

        stderr: SplitParser {
            splitMarker: "\n"
            onRead: (data) => {
                connectProc.errorBuf += data + "\n";
            }
        }

    }

    // Disconnect process
    Process {
        id: disconnectProc

        onRunningChanged: {
            if (!running)
                Qt.callLater(() => {
                    root.refreshDevices();
                });

        }
    }

    // Pair process
    Process {
        id: pairProc

        property string errorBuf: ""

        onRunningChanged: {
            if (running) {
                errorBuf = "";
                return ;
            }
            root.isPairing = false;
            let targetAddr = root.pairingAddress;
            root.pairingAddress = "";
            let err = errorBuf.trim();
            errorBuf = "";
            if (exitCode !== 0) {
                if (err.includes("AuthenticationFailed") || err.includes("Failed"))
                    root.errorMessage = "Pairing failed or timed out";
                else if (err.length > 0)
                    root.errorMessage = err.split("\n")[0];
                else
                    root.errorMessage = "Failed to pair with " + targetAddr;
            } else {
                root.errorMessage = "";
            }
            Qt.callLater(() => {
                root.refreshDevices();
            });
        }

        stderr: SplitParser {
            splitMarker: "\n"
            onRead: (data) => {
                pairProc.errorBuf += data + "\n";
            }
        }

    }

    // Forget process
    Process {
        id: forgetProc

        onRunningChanged: {
            if (!running)
                Qt.callLater(() => {
                    root.refreshDevices();
                });

        }
    }

    // Adapter state change connections
    Connections {
        function onStateChanged() {
            root.refreshDevices();
        }

        function onDiscoveringChanged() {
            const adapter = QsBluetooth.Bluetooth.defaultAdapter;
            if (adapter)
                root.isScanning = adapter.discovering || scanProc.running;

            root.refreshDevices();
        }

        target: QsBluetooth.Bluetooth.defaultAdapter
    }

    // Periodic refresh timer
    Timer {
        id: refreshTimer

        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.refreshDevices();
        }
    }

}
