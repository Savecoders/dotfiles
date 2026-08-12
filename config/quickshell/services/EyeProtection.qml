pragma Singleton
import QtMultimedia
import QtQuick
import Quickshell
import qs.core

Singleton {
    id: root

    readonly property int minutes: (Config.settings && Config.settings.minutesBetweenHealthNotif !== undefined) ? Config.settings.minutesBetweenHealthNotif : 30
    readonly property bool isEnabled: root.minutes > 0

    function runNotify() {
        Quickshell.execDetached(["notify-send", "-i", Quickshell.shellDir + "/assets/icon.png", "-a", "EyeProtection", "Protect your eyes :(", "Look around and take a break."]);
        effectSound.play();
    }

    SoundEffect {
        id: effectSound

        source: Quickshell.shellDir + "/assets/break_notif.wav"
    }

    Timer {
        id: healthTimer

        interval: Math.max(60000, root.minutes * 60000)
        running: root.isEnabled
        repeat: true
        onTriggered: root.runNotify()
    }

    Connections {
        function onMinutesBetweenHealthNotifChanged() {
            healthTimer.restart();
        }

        target: Config.settings ? Config.settings : null
    }

}
