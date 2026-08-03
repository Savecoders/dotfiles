import QtQuick
import Quickshell
import Quickshell.Io
import qs.core
pragma Singleton

Singleton {
    id: root

    property int percent
    property bool charging

    function getBatteryColour(percent) {
        if (percent >= 40)
            return Accents.green;

        return Accents.red;
    }

    Process {
        id: batProc

        command: ["cat", "/sys/class/power_supply/BAT0/capacity"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                const val = parseInt(String(data || "").trim(), 10);
                if (!isNaN(val))
                    root.percent = val;

            }
        }

    }

    Process {
        id: batProcStatus

        command: ["cat", "/sys/class/power_supply/BAT0/status"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                const status = String(data || "").trim();
                root.charging = (status === "Charging" || status === "Full");
            }
        }

    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: {
            if (!batProc.running)
                batProc.running = true;

            if (!batProcStatus.running)
                batProcStatus.running = true;

        }
    }

}
