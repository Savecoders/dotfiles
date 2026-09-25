import QtQuick
import Quickshell
import Quickshell.Bluetooth as QsBluetooth
import Quickshell.Io
import qs.services
pragma Singleton

Singleton {
    id: root

    property string textLabel: "Bluetooth Off"
    property string iconName: "bluetooth_disabled"

    function updateStatus() {
        const adapter = QsBluetooth.Bluetooth.defaultAdapter;
        if (!adapter || adapter.state <= QsBluetooth.BluetoothAdapterState.Disabled) {
            root.textLabel = "Bluetooth Off";
            root.iconName = "bluetooth_disabled";
            return ;
        }
        const devices = (adapter.devices && adapter.devices.values) ? adapter.devices.values : [];
        const connectedDevices = devices.filter((d) => {
            return d && d.connected;
        });
        if (adapter.state === QsBluetooth.BluetoothAdapterState.Enabled && connectedDevices.length === 0) {
            root.textLabel = "Not Connected";
            root.iconName = "bluetooth_searching";
            return ;
        }
        if (connectedDevices.length === 1)
            root.textLabel = connectedDevices[0].name || "Connected";
        else
            root.textLabel = `${connectedDevices.length} Connections`;
        root.iconName = "bluetooth";
    }

    function getBool() {
        const adapter = QsBluetooth.Bluetooth.defaultAdapter;
        if (!adapter || adapter.state <= QsBluetooth.BluetoothAdapterState.Disabled)
            return false;

        return adapter.state === QsBluetooth.BluetoothAdapterState.Enabled;
    }

    function getIcon() {
        return root.iconName;
    }

    function toggle() {
        BluetoothService.toggleBluetooth();
        Qt.callLater(() => {
            root.updateStatus();
        });
        refreshTimer.restart();
    }

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
                root.updateStatus();
            });
        }
    }

    Connections {
        function onStateChanged() {
            root.updateStatus();
            BluetoothService.refreshDevices();
        }

        target: QsBluetooth.Bluetooth.defaultAdapter
    }

    Timer {
        id: refreshTimer

        interval: 15000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.updateStatus();
        }
    }

}
