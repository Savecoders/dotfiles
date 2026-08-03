import QtQuick
import Quickshell
import Quickshell.Io
import qs.core
pragma Singleton

Singleton {
    id: root

    property bool isNightmodeOn: false

    function turnOn() {
        isNightmodeOn = true;
        let temp = parseInt(Config.settings.nightmodeColourTemp) || 4500;
        // Hyprland official night light tool: hyprsunset -t <temperature>
        Quickshell.execDetached(["bash", "-c", "hyprsunset -t " + temp + " || gammastep -O " + temp + " || hyprshade on blue-light-filter"]);
    }

    function turnOff() {
        isNightmodeOn = false;
        Quickshell.execDetached(["bash", "-c", "pkill -f hyprsunset; pkill -f gammastep; hyprshade off"]);
    }

    function toggle() {
        if (isNightmodeOn)
            turnOff();
        else
            turnOn();
    }

    Timer {
        id: checkTimer

        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            checkProc.running = true;
        }
    }

    Process {
        id: checkProc

        command: ["bash", "-c", "pgrep hyprsunset || pgrep gammastep || hyprshade current | grep -q blue-light-filter"]
        onExited: (exitCode) => {
            root.isNightmodeOn = (exitCode === 0);
        }
    }

}
