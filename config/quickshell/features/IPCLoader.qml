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
    property bool isBatteryOpen: false
    property real batteryX: 0
    property real batteryY: 0
    property real batteryWidth: 0
    property real batteryHeight: 0
    property var batteryScreen: null
    property bool isRecordingOpen: false
    property real recordingX: 0
    property real recordingY: 0
    property real recordingWidth: 0
    property real recordingHeight: 0
    property var recordingScreen: null
    property var widgetGeometries: ({
    })

    function calculateItemGeometry(item) {
        if (!item)
            return {
            "x": 0,
            "y": 0,
            "width": 0,
            "height": 0,
            "screen": null
        };

        let win = item.Window ? item.Window.window : null;
        let pt = item.mapToItem(null, 0, 0);
        let winX = 0;
        let winY = 0;
        let scr = win ? win.screen : null;
        let scrW = (scr && scr.width) ? scr.width : 1920;
        let scrH = (scr && scr.height) ? scr.height : 1080;
        let barPos = Config.barPosition;
        if (win) {
            if (barPos === "bottom")
                winY = scrH - win.height;
            else if (barPos === "right")
                winX = scrW - win.width;
        }
        return {
            "x": winX + pt.x,
            "y": winY + pt.y,
            "width": item.width,
            "height": item.height,
            "screen": scr
        };
    }

    function setWidgetGeometry(widgetId, item) {
        let geo = calculateItemGeometry(item);
        let copy = Object.assign({
        }, widgetGeometries);
        copy[widgetId] = geo;
        widgetGeometries = copy;
        return geo;
    }

    function getWidgetGeometry(widgetId) {
        return widgetGeometries[widgetId] || {
            "x": 0,
            "y": 0,
            "width": 0,
            "height": 0,
            "screen": null
        };
    }

    function toggleRecording() {
        root.isRecordingOpen = !root.isRecordingOpen;
    }

    function toggleRecordingAt(item) {
        if (root.isRecordingOpen) {
            root.isRecordingOpen = false;
            return ;
        }
        if (item) {
            let geo = setWidgetGeometry("recording", item);
            root.recordingX = geo.x;
            root.recordingY = geo.y;
            root.recordingWidth = geo.width;
            root.recordingHeight = geo.height;
            root.recordingScreen = geo.screen;
        }
        root.isRecordingOpen = true;
    }

    function toggleBattery() {
        root.isBatteryOpen = !root.isBatteryOpen;
    }

    function toggleBatteryAt(item) {
        if (root.isBatteryOpen) {
            root.isBatteryOpen = false;
            return ;
        }
        if (item) {
            let geo = setWidgetGeometry("battery", item);
            root.batteryX = geo.x;
            root.batteryY = geo.y;
            root.batteryWidth = geo.width;
            root.batteryHeight = geo.height;
            root.batteryScreen = geo.screen;
        }
        root.isBatteryOpen = true;
    }

    function toggleLoadingScreen() {
        root.isLoadingScreenOpen = !root.isLoadingScreenOpen;
    }

    function toggleBar() {
        if ((!Config.settings || !Config.settings.componentControl || !Config.settings.componentControl.barIsEnabled) && !root.isBarOpen)
            return ;

        root.isBarOpen = !root.isBarOpen;
    }

    function toggleSettings() {
        root.isSettingsOpen = !root.isSettingsOpen;
    }

    function toggleDashboard() {
        if ((!Config.settings || !Config.settings.componentControl || !Config.settings.componentControl.dashboardIsEnabled) && !root.isDashboardOpen)
            return ;

        root.isDashboardOpen = !root.isDashboardOpen;
    }

    function toggleLockscreen() {
        if ((!Config.settings || !Config.settings.componentControl || !Config.settings.componentControl.lockscreenIsEnabled) && !root.isLockscreenOpen)
            return ;

        root.isLockscreenOpen = !root.isLockscreenOpen;
    }

    function toggleNotifications() {
        if ((!Config.settings || !Config.settings.componentControl || !Config.settings.componentControl.notifsIsEnabled) && !root.isNotificationsOpen)
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

        target: (Config.settings && Config.settings.componentControl) ? Config.settings.componentControl : null
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

        function toggleBattery() {
            root.toggleBattery();
        }

        function toggleRecording() {
            root.toggleRecording();
        }

        function setWallpaper(path: string) {
            Wallpaper.setNewWallpaper(path);
        }

        function clearNotifs() {
            Notifications.discardAllNotifications();
        }

        function runEyeProtection() {
            EyeProtection.runNotify();
        }

        target: "root"
    }

}
