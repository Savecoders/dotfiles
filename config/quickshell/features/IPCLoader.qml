import QtQuick
import Quickshell
import Quickshell.Io
import qs.core
import qs.services
pragma Singleton

Singleton {
    id: root

    property bool isLoadingScreenOpen: false
    property bool isBarOpen: true
    property bool isSettingsOpen: false
    property bool isDashboardOpen: false
    property bool isLockscreenOpen: false
    property bool isNotificationsOpen: false

    function toggleLoadingScreen() {
        root.isLoadingScreenOpen = !root.isLoadingScreenOpen;
    }

    function toggleBar() {
        if (!Config.settings.componentControl.barIsEnabled && !root.isBarOpen)
            return ;

        root.isBarOpen = !root.isBarOpen;
    }

    function toggleSettings() {
        root.isSettingsOpen = !root.isSettingsOpen;
    }

    function toggleDashboard() {
        if (!Config.settings.componentControl.dashboardIsEnabled && !root.isDashboardOpen)
            return ;

        root.isDashboardOpen = !root.isDashboardOpen;
    }

    function toggleLockscreen() {
        if (!Config.settings.componentControl.lockscreenIsEnabled && !root.isLockscreenOpen)
            return ;

        root.isLockscreenOpen = !root.isLockscreenOpen;
    }

    function toggleNotifications() {
        if (!Config.settings.componentControl.notifsIsEnabled && !root.isNotificationsOpen)
            return ;

        root.isNotificationsOpen = !root.isNotificationsOpen;
    }

    Connections {
        function onBarIsEnabledChanged() {
            if (!Config.settings.componentControl.barIsEnabled)
                root.isBarOpen = false;
            else
                root.isBarOpen = true;
        }

        function onDashboardIsEnabledChanged() {
            if (!Config.settings.componentControl.dashboardIsEnabled)
                root.isDashboardOpen = false;

        }

        function onLockscreenIsEnabledChanged() {
            if (!Config.settings.componentControl.lockscreenIsEnabled)
                root.isLockscreenOpen = false;

        }

        function onNotifsIsEnabledChanged() {
            if (!Config.settings.componentControl.notifsIsEnabled)
                root.isNotificationsOpen = false;

        }

        target: Config.settings.componentControl
    }

    IpcHandler {
        function toggleLoadingScreen() {
            root.toggleLoadingScreen();
        }

        function toggleBar() {
            root.toggleBar();
        }

        function toggleSettings() {
            root.toggleSettings();
        }

        function toggleDashboard() {
            root.toggleDashboard();
        }

        function toggleLockscreen() {
            root.toggleLockscreen();
        }

        function toggleNotifications() {
            root.toggleNotifications();
        }

        function setWallpaper(path: string) {
            Wallpaper.setNewWallpaper(path);
        }

        function clearNotifs() {
            Notifications.discardAllNotifications();
        }

        target: "root"
    }

}
