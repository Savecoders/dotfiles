import QtQuick
import Quickshell
import Quickshell.Io
import qs.services
pragma Singleton

Singleton {
    id: root

    property string textLabel: "Disconnected"
    property string connectionType: "none"
    property string stateName: "disconnected"
    property int signalStrength: 0
    property string iconName: "signal_wifi_statusbar_not_connected"

    function getBool() {
        return root.stateName === "connected" && root.textLabel !== "Disconnected" && root.textLabel !== "Network Off";
    }

    function getIcon() {
        return root.iconName;
    }

    function disconnectActive() {
        if (WifiService.activeSsid !== "")
            WifiService.disconnectNetwork(WifiService.activeSsid);

        if (root.textLabel !== "" && root.textLabel !== "Disconnected" && root.textLabel !== "Network Off") {
            let ethCmd = "nmcli connection down id \"" + root.textLabel + "\" 2>/dev/null; DEV=$(nmcli -t -f DEVICE,TYPE device status 2>/dev/null | grep ':ethernet$' | head -n1 | cut -d: -f1); [ -n \"$DEV\" ] && nmcli device disconnect \"$DEV\" 2>/dev/null || true";
            Quickshell.execDetached(["sh", "-c", ethCmd]);
        }
        let allCmd = "for u in $(nmcli -t -f UUID connection show --active 2>/dev/null); do nmcli connection down uuid \"$u\" 2>/dev/null; done; DEV=$(nmcli -t -f DEVICE,TYPE device status 2>/dev/null | grep -E ':(wifi|ethernet)$' | head -n1 | cut -d: -f1); [ -n \"$DEV\" ] && nmcli device disconnect \"$DEV\" 2>/dev/null || true";
        Quickshell.execDetached(["sh", "-c", allCmd]);
        root.textLabel = "Disconnected";
        root.stateName = "disconnected";
        WifiService.activeSsid = "";
        WifiService.activeSignal = 0;
        WifiService.scan(false);
    }

    function toggle() {
        if (root.getBool()) {
            root.disconnectActive();
        } else {
            let cmd = "nmcli networking on 2>/dev/null; DEV=$(nmcli -t -f DEVICE,TYPE device status 2>/dev/null | grep -E ':(ethernet|wifi)$' | head -n1 | cut -d: -f1); [ -n \"$DEV\" ] && nmcli device connect \"$DEV\" 2>/dev/null || nmcli radio wifi on";
            Quickshell.execDetached(["sh", "-c", cmd]);
            WifiService.scan(true);
        }
    }

    Process {
        id: isConnectedProc

        command: [Quickshell.shellDir + "/lib/network.out", "--watch"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                let raw = String(data).trim();
                if (raw.startsWith("{") && raw.endsWith("}")) {
                    try {
                        let parsed = JSON.parse(raw);
                        root.textLabel = parsed.name || "Disconnected";
                        root.connectionType = parsed.type || "none";
                        root.stateName = parsed.state || "disconnected";
                        root.signalStrength = parsed.strength || 0;
                        root.iconName = parsed.icon || "signal_wifi_statusbar_not_connected";
                        return ;
                    } catch (e) {
                    }
                }
                root.textLabel = raw;
                if (raw === "Disconnected") {
                    root.iconName = "signal_wifi_statusbar_not_connected";
                    root.stateName = "disconnected";
                } else if (raw === "Network Off") {
                    root.iconName = "signal_wifi_bad";
                    root.stateName = "off";
                } else {
                    root.iconName = "lan";
                    root.stateName = "connected";
                }
            }
        }

    }

}
