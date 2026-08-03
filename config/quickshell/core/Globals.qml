pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property QtObject visibility
    property QtObject states

    visibility: QtObject {
        property bool powermenu: false
        property bool launcher: false
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
