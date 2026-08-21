import QtQuick
import Quickshell
import Quickshell.Io
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
