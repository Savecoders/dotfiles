pragma Singleton
import QtQuick
import Quickshell
import qs.core

Singleton {
    id: root

    readonly property var targetScreens: {
        const screens = Quickshell.screens || [];
        const target = (Config.settings && Config.settings.desktop && Config.settings.desktop.targetScreen) ? Config.settings.desktop.targetScreen : "all";
        if (target === "all" || target === "")
            return screens;

        const found = screens.find((s) => {
            return s && s.name === target;
        });
        return found ? [found] : screens;
    }
    property QtObject visibility
    property QtObject states

    visibility: QtObject {
        property bool powermenu: false
        property bool dashboard: false
        property bool sidebarRight: false
        property bool sidebarLeft: false
        property int sidebarLeftWidth: 480
        property int sidebarRightWidth: 500
    }

    states: QtObject {
        property bool settingsOpen: false
        property bool barOpen: true
    }

}
