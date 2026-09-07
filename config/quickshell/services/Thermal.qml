import QtQuick
import Quickshell
import Quickshell.Io
import qs.core
import qs.features
pragma Singleton

Singleton {
    id: root

    property int temp: 0

    FileView {
        id: thermalZone

        path: "/sys/class/thermal/thermal_zone0/temp"
    }

    Process {
        id: tempProc

        command: ["sh", "-c", "for f in /sys/class/hwmon/hwmon*/temp1_input /sys/class/hwmon/hwmon*/temp2_input; do if [ -f \"$f\" ]; then cat \"$f\" && exit; fi; done 2>/dev/null || sensors 2>/dev/null | grep -i 'Package id 0:\\|Tctl:' | awk '{print $3}' | tr -d '+°C' | head -n1"]

        stdout: StdioCollector {
            onStreamFinished: {
                let textVal = text.trim();
                if (textVal) {
                    let val = parseFloat(textVal);
                    if (!isNaN(val)) {
                        if (val > 1000)
                            val = val / 1000;

                        root.temp = Math.round(val);
                    }
                }
            }
        }

    }

    Timer {
        interval: 3000
        running: !Idle.monitorsOff && (typeof IPCLoader !== "undefined" && IPCLoader ? !IPCLoader.isLockscreenOpen : true)
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            thermalZone.reload();
            let rawStr = thermalZone.text().trim();
            let raw = parseInt(rawStr);
            if (!isNaN(raw) && raw > 0) {
                root.temp = Math.round(raw / 1000);
            } else {
                if (!tempProc.running)
                    tempProc.running = true;

            }
        }
    }

}
