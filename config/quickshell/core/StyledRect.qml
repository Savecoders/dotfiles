import QtQuick
import Quickshell
import qs.core

Rectangle {
    id: root

    property string variant: "common" // "pane", "popup", "common", "internalbg", "focus"
    property bool useDefaultRadius: true

    radius: useDefaultRadius ? Config.settings.borderRadius : root.radius

    color: {
        switch (variant) {
        case "pane":
            return Qt.alpha(Colours.palette.surface_container, 0.95);
        case "popup":
            return Qt.alpha(Colours.palette.surface_container_high, 0.98);
        case "internalbg":
            return Qt.alpha(Colours.palette.surface_container_low, 0.8);
        case "focus":
            return Qt.alpha(Colours.palette.primary_container, 0.9);
        case "common":
        default:
            return Colours.palette.surface;
        }
    }

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
