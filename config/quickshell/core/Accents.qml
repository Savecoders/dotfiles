import QtQuick
import Quickshell
import qs.core
pragma Singleton

Singleton {
    id: root

    readonly property color green: Colours.get("green", "#b4dbc0")
    readonly property color red: Colours.get("error", "#dbbbb4")
    readonly property color disab: Colours.get("outline", "#848585")
}
