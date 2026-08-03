import QtMultimedia
import QtQuick
import Quickshell
import qs.core

Scope {
    id: root

    function runNotify() {
        Quickshell.execDetached(["notify-send", "Protect your eyes :(", "Look around and take a break."]);
        effectSound.play();
    }

    SoundEffect {
        id: effectSound

        source: Quickshell.shellDir + "/assets/break_notif.wav"
    }

    Timer {
        interval: Config.settings.minutesBetweenHealthNotif * 60000
        running: Config.settings.minutesBetweenHealthNotif == -1 ? false : true
        repeat: Config.settings.minutesBetweenHealthNotif == -1 ? false : true
        onTriggered: root.runNotify()
    }

}
