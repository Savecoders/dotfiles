import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property string username: Quickshell.env("USER") || Quickshell.env("LOGNAME") || "user"
    property string uptime: ""

    FileView {
        id: procUptime

        path: "/proc/uptime"
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            procUptime.reload();
            let raw = procUptime.text().trim().split(" ")[0];
            let sec = parseInt(raw) || 0;
            let days = Math.floor(sec / 86400);
            let hours = Math.floor((sec % 86400) / 3600);
            let mins = Math.floor((sec % 3600) / 60);
            if (days > 0)
                root.uptime = `${days}d ${hours}h ${mins}m`;
            else if (hours > 0)
                root.uptime = `${hours}h ${mins}m`;
            else
                root.uptime = `${mins}m`;
        }
    }

}
