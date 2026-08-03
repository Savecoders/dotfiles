import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property string uptime
    property string username

    Process {
        id: uptimeProc

        command: ["bash", "-c", "$HOME/.config/quickshell/lib/uptime"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                return root.uptime = `${data}`;
            }
        }

    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: {
            if (!uptimeProc.running)
                uptimeProc.running = true;

        }
    }

    Process {
        id: usernameProc

        command: ["whoami"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                return root.username = `${data}`;
            }
        }

    }

}
