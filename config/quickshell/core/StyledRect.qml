import QtQuick
import Quickshell
import qs.core

Rectangle {
    id: root

    property string variant: "common" // "pane", "popup", "common", "internalbg", "focus"
    property bool useDefaultRadius: true
    property int customRadius: 0

    readonly property bool transparencyEnabled: Transparency.enabled
    readonly property real globalOpacity: Transparency.opacity

    radius: useDefaultRadius ? Config.get("borderRadius", 20) : root.customRadius
    color: Transparency.colorFor(variant)
    border.color: {
        switch (variant) {
        case "focus":
            return Colours.palette.primary;
        case "popup":
        case "pane":
            return Colours.palette.outline_variant;
        default:
            return "transparent";
        }
    }
    border.width: (variant === "focus" || variant === "popup" || variant === "pane") ? 1 : 0
}
