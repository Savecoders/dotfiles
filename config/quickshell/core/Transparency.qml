import QtQuick
import Quickshell
import qs.core
pragma Singleton

Singleton {
    id: root

    readonly property bool enabled: Config.settings.theme.transparency.enabled
    readonly property real opacity: Config.settings.theme.transparency.opacity

    function factorFor(variant) {
        switch (variant) {
        case "pane":
            return 0.95;
        case "popup":
            return 0.98;
        case "internalbg":
            return 0.85;
        case "focus":
            return 0.95;
        case "common":
        default:
            return 1;
        }
    }

    function baseColorFor(variant) {
        switch (variant) {
        case "pane":
            return Colours.palette.surface_container;
        case "popup":
            return Colours.palette.surface_container_high;
        case "internalbg":
            return Colours.palette.surface_container_low;
        case "focus":
            return Colours.palette.primary_container;
        case "common":
        default:
            return Colours.palette.surface;
        }
    }

    function colorFor(variant, customBaseColor) {
        let col = (customBaseColor !== undefined && customBaseColor !== null) ? customBaseColor : baseColorFor(variant);
        if (!enabled)
            return col;

        let factor = factorFor(variant);
        return Qt.alpha(col, Math.max(0.05, Math.min(1, opacity * factor)));
    }

    function applyAlpha(col, factor) {
        if (!enabled)
            return col;

        let f = (factor !== undefined && factor !== null) ? factor : 1;
        return Qt.alpha(col, Math.max(0.05, Math.min(1, opacity * f)));
    }

}
