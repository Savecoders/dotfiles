import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property int brightnessPercent: 50
    property int maxBrightness: 100
    property int lastRaw: -1

    function getBrightnessPercent(p) {
        if (maxBrightness > 0) {
            const pct = Math.max(0, Math.min(100, Math.round((p / maxBrightness) * 100)));
            if (pct !== brightnessPercent)
                brightnessPercent = pct;

        }
    }

    function setBrightnessPercent(p) {
        const clamped = Math.max(0, Math.min(100, Math.round(p)));
        brightnessPercent = clamped;
        Quickshell.execDetached(["brightnessctl", "s", `${clamped}%`]);
    }

    function update() {
        if (brightnessFile.path !== "") {
            brightnessFile.reload();
            const raw = parseInt(brightnessFile.text().trim());
            if (!isNaN(raw))
                getBrightnessPercent(raw);

        }
    }

    Process {
        id: initProc

        running: true
        command: ["brightnessctl", "-m", "info"]

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                const parts = data.trim().split(",");
                if (parts.length >= 5) {
                    const devName = parts[0];
                    const currRaw = parseInt(parts[2]);
                    const maxRaw = parseInt(parts[4]);
                    if (!isNaN(maxRaw) && maxRaw > 0)
                        root.maxBrightness = maxRaw;

                    if (devName)
                        brightnessFile.path = "/sys/class/backlight/" + devName + "/brightness";

                    if (!isNaN(currRaw))
                        root.getBrightnessPercent(currRaw);

                }
            }
        }

    }

    FileView {
        id: brightnessFile

        path: "/sys/class/backlight/intel_backlight/brightness"
    }

    Timer {
        id: pollTimer

        interval: 150
        running: true
        repeat: true
        onTriggered: {
            if (brightnessFile.path !== "") {
                brightnessFile.reload();
                const raw = parseInt(brightnessFile.text().trim());
                if (!isNaN(raw) && raw !== root.lastRaw) {
                    root.lastRaw = raw;
                    root.getBrightnessPercent(raw);
                }
            }
        }
    }

}
