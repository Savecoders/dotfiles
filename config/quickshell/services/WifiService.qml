import QtQuick
import Quickshell
import Quickshell.Io
import qs.core
import qs.features
pragma Singleton

Singleton {
    id: root

    property bool wifiEnabled: true
    property bool isScanning: false
    property bool isConnecting: false
    property string connectingSsid: ""
    property string activeSsid: ""
    property int activeSignal: 0
    property string errorMessage: ""
    property var savedSsids: ({
    })
    property var networks: []

    // Helper: Material icon based on signal strength and connectivity
    function getWifiIcon(signal, isConnected, isSecure) {
        if (!root.wifiEnabled)
            return "wifi_off";

        if (signal <= 0 && !isConnected)
            return "signal_wifi_0_bar";

        if (signal <= 25)
            return "network_wifi_1_bar";

        if (signal <= 50)
            return "network_wifi_2_bar";

        if (signal <= 75)
            return "network_wifi_3_bar";

        return "network_wifi";
    }

    // Trigger Wi-Fi network scan
    function scan(explicitRescan) {
        if (scanProc.running)
            return ;

        root.isScanning = true;
        let cmd = "nmcli radio wifi; echo '==='; nmcli -t -f NAME,TYPE connection show; echo '==='; nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device status; echo '---'; nmcli -t -f IN-USE,SSID,SECURITY,SIGNAL,FREQ dev wifi list" + (explicitRescan ? " --rescan yes" : " --rescan auto");
        scanProc.command = ["sh", "-c", cmd];
        scanProc.running = true;
    }

    // Connect to a network (saved, password-protected, or open)
    function connectToNetwork(ssid, password) {
        if (!ssid || ssid === "" || root.isConnecting)
            return ;

        root.isConnecting = true;
        root.connectingSsid = ssid;
        root.errorMessage = "";
        let isSaved = !!root.savedSsids[ssid];
        if (isSaved && (!password || password === ""))
            connectProc.command = ["nmcli", "connection", "up", "id", ssid];
        else if (password && password !== "")
            connectProc.command = ["nmcli", "dev", "wifi", "connect", ssid, "password", password];
        else
            connectProc.command = ["nmcli", "dev", "wifi", "connect", ssid];
        connectProc.running = true;
    }

    // Disconnect active connection
    function disconnectNetwork(ssid) {
        let cmd = "DEV=$(nmcli -t -f DEVICE,TYPE device status 2>/dev/null | grep ':wifi$' | head -n1 | cut -d: -f1);";
        if (ssid && ssid !== "")
            cmd += " nmcli connection down id \"" + ssid + "\" 2>/dev/null;";

        cmd += " [ -n \"$DEV\" ] && nmcli device disconnect \"$DEV\" 2>/dev/null || true";
        Quickshell.execDetached(["sh", "-c", cmd]);
        root.activeSsid = "";
        root.activeSignal = 0;
        root.scan(false);
    }

    // Forget a saved network profile
    function forgetNetwork(ssid) {
        if (!ssid || ssid === "")
            return ;

        let cmd = "nmcli connection delete id \"" + ssid + "\" 2>/dev/null; DEV=$(nmcli -t -f DEVICE,TYPE device status 2>/dev/null | grep ':wifi$' | head -n1 | cut -d: -f1); [ -n \"$DEV\" ] && nmcli device disconnect \"$DEV\" 2>/dev/null || true";
        Quickshell.execDetached(["sh", "-c", cmd]);
        if (root.activeSsid === ssid) {
            root.activeSsid = "";
            root.activeSignal = 0;
        }
        delete root.savedSsids[ssid];
        root.scan(true);
    }

    // Toggle Wi-Fi radio on/off
    function toggleWifi() {
        radioProc.command = ["nmcli", "radio", "wifi", root.wifiEnabled ? "off" : "on"];
        radioProc.running = true;
    }

    // Open system network connection editor
    function openSettings() {
        Quickshell.execDetached(["nm-connection-editor"]);
    }

    // Parse combined output from scanProc
    function parseScanOutput(output) {
        if (!output || output.length === 0)
            return ;

        let parts = output.split("---");
        let headerPart = parts[0] || "";
        let wifiPart = parts.length > 1 ? parts.slice(1).join("---") : "";
        // Parse radio and saved connections
        let headerSections = headerPart.split("===");
        let radioStr = (headerSections[0] || "").trim();
        root.wifiEnabled = (radioStr === "enabled");
        let savedMap = {
        };
        if (headerSections.length > 1) {
            let savedLines = headerSections[1].split("\n");
            for (let i = 0; i < savedLines.length; i++) {
                let line = savedLines[i].trim();
                if (line.length === 0)
                    continue;

                let colonIdx = line.lastIndexOf(":");
                if (colonIdx > 0) {
                    let name = line.substring(0, colonIdx);
                    let type = line.substring(colonIdx + 1);
                    if (type === "802-11-wireless" && name.length > 0)
                        savedMap[name] = true;

                }
            }
        }
        root.savedSsids = savedMap;
        // Parse device status for connected wifi
        let devActiveWifi = "";
        if (headerSections.length > 2) {
            let devLines = headerSections[2].split("\n");
            for (let i = 0; i < devLines.length; i++) {
                let dparts = devLines[i].trim().split(":");
                if (dparts.length >= 4 && dparts[1] === "wifi" && dparts[2] === "connected")
                    devActiveWifi = dparts.slice(3).join(":").trim();

            }
        }
        // Parse available Wi-Fi access points
        let wifiLines = wifiPart.split("\n");
        let dedup = {
        };
        let activeFound = devActiveWifi;
        let activeSig = 0;
        for (let i = 0; i < wifiLines.length; i++) {
            let rawLine = wifiLines[i].trim();
            if (rawLine.length === 0)
                continue;

            let lineParts = rawLine.split(":");
            if (lineParts.length < 5)
                continue;

            let inUse = (lineParts[0].trim() === "*") || (devActiveWifi !== "" && rawLine.includes(devActiveWifi));
            let freq = lineParts.pop() || "";
            let signal = parseInt(lineParts.pop(), 10);
            if (isNaN(signal))
                signal = 0;

            let security = lineParts.pop() || "";
            let ssid = lineParts.slice(1).join(":");
            if (!ssid || ssid === "" || ssid.trim() === "")
                continue;

            if (devActiveWifi !== "" && ssid === devActiveWifi)
                inUse = true;

            let isSecure = (security !== "" && security !== "--");
            let freqNum = parseInt(freq, 10);
            let is5G = (!isNaN(freqNum) && freqNum >= 4900) || freq.toLowerCase().indexOf("5 ghz") !== -1 || freq.toLowerCase().indexOf("5ghz") !== -1;
            let isSaved = !!savedMap[ssid];
            if (inUse) {
                activeFound = ssid;
                activeSig = signal;
            }
            if (!dedup[ssid]) {
                dedup[ssid] = {
                    "ssid": ssid,
                    "signal": signal,
                    "security": security,
                    "isSecure": isSecure,
                    "isSaved": isSaved,
                    "isConnected": inUse,
                    "is5GHz": is5G,
                    "icon": root.getWifiIcon(signal, inUse, isSecure)
                };
            } else {
                if (signal > dedup[ssid].signal) {
                    dedup[ssid].signal = signal;
                    dedup[ssid].icon = root.getWifiIcon(signal, inUse, isSecure);
                }
                dedup[ssid].is5GHz = dedup[ssid].is5GHz || is5G;
                if (inUse)
                    dedup[ssid].isConnected = true;

            }
        }
        root.activeSsid = activeFound;
        root.activeSignal = activeSig;
        // Convert map to list and sort: Connected first, then by signal strength descending
        let list = Object.values(dedup);
        list.sort((a, b) => {
            if (a.isConnected !== b.isConnected)
                return a.isConnected ? -1 : 1;

            if (a.isSaved !== b.isSaved)
                return a.isSaved ? -1 : 1;

            return b.signal - a.signal;
        });
        root.networks = list;
    }

    Component.onCompleted: {
        Qt.callLater(() => {
            root.scan(false);
        });
    }

    // Periodic scan timer (active when UI is open or every 30s)
    Timer {
        id: autoScanTimer

        interval: 30000
        running: true
        repeat: true
        onTriggered: {
            if (IPCLoader.isWifiOpen || IPCLoader.isDashboardOpen)
                root.scan(false);

        }
    }

    // Scan process: collects radio state, saved connections, and wifi list
    Process {
        id: scanProc

        property string rawStdout: ""

        onRunningChanged: {
            if (running) {
                rawStdout = "";
                return ;
            }
            root.isScanning = false;
            let fullText = rawStdout;
            rawStdout = "";
            Qt.callLater(() => {
                root.parseScanOutput(fullText);
            });
        }

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (data) => {
                scanProc.rawStdout += data + "\n";
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
            let targetSsid = root.connectingSsid;
            root.connectingSsid = "";
            let err = errorBuf.trim();
            errorBuf = "";
            if (exitCode !== 0) {
                if (err.includes("Secrets were required") || err.includes("passwords or encryption keys are required"))
                    root.errorMessage = "Incorrect password or credentials required";
                else if (err.includes("No network with SSID"))
                    root.errorMessage = "Network not found or out of range";
                else if (err.length > 0)
                    root.errorMessage = err.split("\n")[0].replace("Error: ", "");
                else
                    root.errorMessage = "Failed to connect to " + targetSsid;
            } else {
                root.errorMessage = "";
                IPCLoader.dashboardWifiView = false;
            }
            // Rescan immediately after connection attempt
            root.scan(false);
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
            if (!running) {
                root.activeSsid = "";
                root.activeSignal = 0;
                root.scan(false);
            }
        }
    }

    // Forget process
    Process {
        id: forgetProc

        onRunningChanged: {
            if (!running)
                root.scan(false);

        }
    }

    // Radio process (toggle Wi-Fi)
    Process {
        id: radioProc

        onRunningChanged: {
            if (!running)
                root.scan(true);

        }
    }

}
