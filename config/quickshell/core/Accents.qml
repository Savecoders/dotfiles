import QtQuick
import Quickshell
import qs.core
pragma Singleton

Singleton {
    id: root

    readonly property color green: Colours.palette.green || "#b4dbc0"
    readonly property color red: Colours.palette.error || "#dbbbb4"
    readonly property color disab: Colours.palette.outline || "#848585"
}
