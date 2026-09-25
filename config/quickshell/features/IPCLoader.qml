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
    property bool isWifiOpen: false
    property real wifiX: 0
    property real wifiY: 0
    property real wifiWidth: 0
    property real wifiHeight: 0
    property var wifiScreen: null
    property bool dashboardWifiView: false
    property bool dashboardBluetoothView: false
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

    function toggleWifi() {
        if (root.isDashboardOpen && root.dashboardWifiView) {
            root.isDashboardOpen = false;
            root.dashboardWifiView = false;
        } else {
            root.dashboardBluetoothView = false;
            root.dashboardWifiView = true;
            root.isDashboardOpen = true;
            WifiService.scan(true);
        }
    }

    function toggleWifiAt(item) {
        toggleWifi();
    }

    function toggleBluetooth() {
        if (root.isDashboardOpen && root.dashboardBluetoothView) {
            root.isDashboardOpen = false;
            root.dashboardBluetoothView = false;
        } else {
            root.dashboardWifiView = false;
            root.dashboardBluetoothView = true;
            root.isDashboardOpen = true;
            BluetoothService.scan(true);
        }
    }

    function toggleBluetoothAt(item) {
        toggleBluetooth();
    }

    function toggleLoadingScreen() {
        root.isLoadingScreenOpen = !root.isLoadingScreenOpen;
    }

    function toggleBar() {
        if (!Config.get("componentControl.barIsEnabled", true) && !root.isBarOpen)
            return ;

        root.isBarOpen = !root.isBarOpen;
    }

    function toggleSettings() {
        root.isSettingsOpen = !root.isSettingsOpen;
    }

    function toggleDashboard() {
        if (!Config.get("componentControl.dashboardIsEnabled", true) && !root.isDashboardOpen)
            return ;

        root.isDashboardOpen = !root.isDashboardOpen;
    }

    function toggleLockscreen() {
        if (!Config.get("componentControl.lockscreenIsEnabled", true) && !root.isLockscreenOpen)
            return ;

        root.isLockscreenOpen = !root.isLockscreenOpen;
    }

    function toggleNotifications() {
        if (!Config.get("componentControl.notifsIsEnabled", true) && !root.isNotificationsOpen)
            return ;

        root.isNotificationsOpen = !root.isNotificationsOpen;
    }

    onIsDashboardOpenChanged: {
        if (!root.isDashboardOpen) {
            root.dashboardWifiView = false;
            root.dashboardBluetoothView = false;
        }
    }
    onIsLockscreenOpenChanged: {
        if (root.isLockscreenOpen) {
            root.isDashboardOpen = false;
            root.isSettingsOpen = false;
            root.isBatteryOpen = false;
            root.isRecordingOpen = false;
            root.isNotificationsOpen = false;
            root.isWifiOpen = false;
            root.dashboardWifiView = false;
            root.dashboardBluetoothView = false;
        }
    }

    Connections {
        function onMonitorsOffChanged() {
            if (Idle.monitorsOff) {
                root.isDashboardOpen = false;
                root.isSettingsOpen = false;
                root.isBatteryOpen = false;
                root.isRecordingOpen = false;
                root.isNotificationsOpen = false;
                root.isWifiOpen = false;
                root.dashboardWifiView = false;
                root.dashboardBluetoothView = false;
            }
        }

        target: Idle
    }

    Connections {
        function onBarIsEnabledChanged() {
            if (!Config.get("componentControl.barIsEnabled", true))
                root.isBarOpen = false;
            else
                root.isBarOpen = true;
        }

        function onDashboardIsEnabledChanged() {
            if (!Config.get("componentControl.dashboardIsEnabled", true))
                root.isDashboardOpen = false;

        }

        function onLockscreenIsEnabledChanged() {
            if (!Config.get("componentControl.lockscreenIsEnabled", true))
                root.isLockscreenOpen = false;

        }

        function onNotifsIsEnabledChanged() {
            if (!Config.get("componentControl.notifsIsEnabled", true))
                root.isNotificationsOpen = false;

        }

        target: Config.get("componentControl", null)
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

        function toggleWifi() {
            root.toggleWifi();
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
