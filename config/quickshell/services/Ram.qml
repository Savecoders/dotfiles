import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property int usage: 0
    property string usedStr: ""
    property string totalStr: ""

    FileView {
        id: memInfo

        path: "/proc/meminfo"
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            memInfo.reload();
            let textContent = memInfo.text();
            if (!textContent)
                return ;

            let lines = textContent.split("\n");
            let memTotal = 0;
            let memAvailable = 0;
            for (let line of lines) {
                if (line.startsWith("MemTotal:")) {
                    let match = line.match(/\d+/);
                    if (match)
                        memTotal = parseInt(match[0]);

                } else if (line.startsWith("MemAvailable:")) {
                    let match = line.match(/\d+/);
                    if (match)
                        memAvailable = parseInt(match[0]);

                }
            }
            if (memTotal > 0) {
                let memUsed = memTotal - memAvailable;
                let pct = Math.round((memUsed / memTotal) * 100);
                root.usage = Math.max(0, Math.min(100, pct));
                root.usedStr = (memUsed / 1024 / 1024 >= 1) ? (memUsed / 1024 / 1024).toFixed(1) + " GB" : Math.round(memUsed / 1024) + " MB";
                root.totalStr = (memTotal / 1024 / 1024 >= 1) ? (memTotal / 1024 / 1024).toFixed(1) + " GB" : Math.round(memTotal / 1024) + " MB";
            }
        }
    }

}
