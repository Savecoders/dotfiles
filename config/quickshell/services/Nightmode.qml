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

    Process {
        id: checkProc

        running: true
        command: ["sh", "-c", "while true; do if pgrep hyprsunset >/dev/null 2>&1 || pgrep gammastep >/dev/null 2>&1 || hyprshade current 2>/dev/null | grep -q blue-light-filter; then echo on; else echo off; fi; sleep 3; done"]

        stdout: SplitParser {
            onRead: (data) => {
                root.isNightmodeOn = (String(data).trim() === "on");
            }
        }
    }

}
