import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property string textLabel

    function getBool() {
        if (root.textLabel == "Disconnected")
            return true;

        if (root.textLabel == "Network Off")
            return false;
        else
            return true;
    }

    function getIcon() {
        if (root.textLabel == "Disconnected")
            return "signal_wifi_statusbar_not_connected";

        if (root.textLabel == "Network Off")
            return "signal_wifi_bad";
        else
            return "signal_wifi_4_bar";
    }

    Process {
        id: isConnectedProc

        command: [Quickshell.shellDir + "/lib/network.out", "--watch"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                return root.textLabel = data;
            }
        }

    }

}
