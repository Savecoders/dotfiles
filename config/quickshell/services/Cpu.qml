import QtQuick
import Quickshell
import Quickshell.Io
import qs.core
import qs.features
pragma Singleton

Singleton {
    id: root

    property int usage: 0
    property double prevIdle: -1
    property double prevTotal: -1

    FileView {
        id: cpuStat

        path: "/proc/stat"
    }

    Timer {
        interval: 3000
        running: !Idle.monitorsOff && (typeof IPCLoader !== "undefined" && IPCLoader ? !IPCLoader.isLockscreenOpen : true)
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuStat.reload();
            let textContent = cpuStat.text();
            if (!textContent)
                return ;

            let lines = textContent.split("\n");
            if (lines.length < 1)
                return ;

            let cpuLine = lines[0].trim().split(/\s+/);
            if (cpuLine.length < 8)
                return ;

            let cpuUser = parseFloat(cpuLine[1]) || 0;
            let cpuNice = parseFloat(cpuLine[2]) || 0;
            let cpuSystem = parseFloat(cpuLine[3]) || 0;
            let cpuIdle = parseFloat(cpuLine[4]) || 0;
            let cpuIowait = parseFloat(cpuLine[5]) || 0;
            let cpuIrq = parseFloat(cpuLine[6]) || 0;
            let cpuSoftirq = parseFloat(cpuLine[7]) || 0;
            let cpuSteal = (cpuLine.length > 8 ? parseFloat(cpuLine[8]) : 0) || 0;
            let cpuIdleAll = cpuIdle + cpuIowait;
            let cpuTotal = cpuUser + cpuNice + cpuSystem + cpuIrq + cpuSoftirq + cpuSteal + cpuIdleAll;
            if (root.prevTotal >= 0) {
                let totalDiff = cpuTotal - root.prevTotal;
                let idleDiff = cpuIdleAll - root.prevIdle;
                if (totalDiff > 0)
                    root.usage = Math.max(0, Math.min(100, Math.round(((totalDiff - idleDiff) / totalDiff) * 100)));

            }
            root.prevTotal = cpuTotal;
            root.prevIdle = cpuIdleAll;
        }
    }

}
