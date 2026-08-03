import QtQuick
import Quickshell
import Quickshell.Io
import qs.features
import qs.services

Scope {
    id: global

    property bool themeNotificationShown: false

    IpcHandler {
        function toggle() {
            IPCLoader.toggleLauncher();
        }

        target: "launcher"
    }

    IpcHandler {
        function toggle() {
            IPCLoader.toggleDashboard();
        }

        target: "dashboard"
    }

    IpcHandler {
        function toggle() {
            Globals.visibility.powermenu = !Globals.visibility.powermenu;
        }

        target: "powermenu"
    }

    IpcHandler {
        function toggle() {
            IPCLoader.toggleBar();
        }

        target: "bar"
    }

    IpcHandler {
        function toggle() {
            IPCLoader.toggleSettings();
        }

        target: "settings"
    }

    IpcHandler {
        function setWallpaper(path: string) {
            Wallpaper.setNewWallpaper(path);
        }

        function clearNotifs() {
            Notifications.discardAllNotifications();
        }

        function toggleDND() {
            Notifications.toggleDND();
        }

        function toggleNightmode() {
            if (Nightmode.isNightmodeOn)
                Nightmode.turnOff();
            else
                Nightmode.turnOn();
        }

        function updateBrightness() {
            Brightness.update();
        }

        target: "global"
    }

}
