import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.core

StyledRect {
    id: root

    property bool isHovered: false
    property var toRun
    property string iconName
    property string bgColour: Colours.palette.surface
    property string colour: Colours.palette.on_surface
    property string bgColourHovered: Colours.palette.surface_container_high
    property string colourHovered: Colours.palette.on_surface

    variant: "internalbg"
    width: 35
    height: 35
    color: isHovered ? root.bgColourHovered : root.bgColour
    radius: isHovered ? Math.max(4, Config.settings.borderRadius - 6) : Math.max(4, Config.settings.borderRadius - 10)

    Text {
        id: icon

        anchors.centerIn: parent
        font.pixelSize: Styling.fontSize.headline
        color: root.isHovered ? root.colourHovered : root.colour
        text: root.iconName
        font.family: Config.settings.iconFont

        Behavior on color {
            PropertyAnimation {
                duration: Config.settings.animationSpeed
                easing.type: Easing.InSine
            }

        }

    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.isHovered = true
        onExited: root.isHovered = false
        onClicked: root.toRun()
    }

    Behavior on color {
        PropertyAnimation {
            duration: Config.settings.animationSpeed
            easing.type: Easing.InSine
        }

    }

    Behavior on radius {
        PropertyAnimation {
            duration: Config.settings.animationSpeed
            easing.type: Easing.InSine
        }

    }

}
