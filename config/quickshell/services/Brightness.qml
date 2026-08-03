import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property int brightnessPercent: 10
    property int maxBrightness: 1500

    function getBrightnessPercent(p) {
        brightnessPercent = (p / maxBrightness) * 100;
    }

    function setBrightnessPercent(p) {
        Quickshell.execDetached(["brightnessctl", "s", `${p}%`]);
    }

    function update() {
        if (brightnessPercentProc.running)
            brightnessPercentProc.running = false;

        brightnessPercentProc.running = true;
    }

    Process {
        id: brightnessPercentProc

        running: true
        command: ["brightnessctl", "g"]

        stdout: SplitParser {
            onRead: (data) => {
                return getBrightnessPercent(parseInt(data));
            }
        }

    }

    FileView {
        path: "/sys/class/backlight/intel_backlight/brightness"
        watchChanges: true
        onTextChanged: {
            const raw = text().trim();
            const val = parseInt(raw);
            if (!isNaN(val))
                getBrightnessPercent(val);

        }
    }

    Process {
        running: true
        command: ["brightnessctl", "m"]

        stdout: SplitParser {
            onRead: (data) => {
                return maxBrightness = parseInt(data) || 1;
            }
        }

    }

}
