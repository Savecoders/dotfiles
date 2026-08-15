import QtQuick
import Quickshell
import Quickshell.Io
import qs.core

StyledRect {
    variant: "internalbg"
    color: Qt.alpha(Colours.palette.surface_container_high, 0.6)
    radius: Config.settings.borderRadius
}
