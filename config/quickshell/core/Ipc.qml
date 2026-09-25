import QtQuick
import Quickshell
import Quickshell.Io
import qs.core
import qs.features
import qs.services
pragma Singleton

Singleton {
    id: root

    property bool themeNotificationShown: false

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

        function toggleShortcuts() {
            SettingsControl.setLocation(7);
            if (!IPCLoader.isSettingsOpen)
                IPCLoader.toggleSettings();

        }

        target: "global"
    }

    IpcHandler {
        function transparencyState() : string {
            return JSON.stringify({
                "enabled": Transparency.enabled,
                "opacity": Transparency.opacity,
                "rawAdapterEnabled": Config.settings.theme.transparency.enabled,
                "configGetEnabled": Config.get("theme.transparency.enabled", false),
                "popupColor": String(Transparency.colorFor("popup"))
            });
        }

        target: "debug"
    }

}
