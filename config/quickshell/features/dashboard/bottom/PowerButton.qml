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

    property string iconCode: "settings"
    property string text: "Placeholder"
    property var toRun
    property bool hovered: false

    variant: "internalbg"
    useDefaultRadius: false
    border.width: 0
    Layout.preferredWidth: hovered ? 110 : 70
    Layout.preferredHeight: 30
    color: hovered ? Colours.palette.primary_container : "transparent"
    radius: Math.max(4, Config.settings.borderRadius - 10)

    Text {
        id: icon

        anchors.left: parent.left
        anchors.leftMargin: Styling.spacing.lg
        anchors.top: parent.top
        anchors.topMargin: 5
        text: root.iconCode
        font.family: Config.settings.iconFont
        font.pixelSize: Styling.fontSize.lg
        color: root.hovered ? Colours.palette.on_primary_container : Qt.alpha(Colours.palette.on_surface, 0.8)

        Behavior on color {
            PropertyAnimation {
                duration: Config.settings.animationSpeed
                easing.type: Easing.InSine
            }

        }

    }

    Text {
        anchors.left: icon.left
        anchors.leftMargin: 20
        anchors.top: parent.top
        anchors.topMargin: 6
        text: root.text
        font.family: Config.settings.font
        font.pixelSize: Styling.fontSize.bodyLarge
        color: root.hovered ? Colours.palette.on_primary_container : Qt.alpha(Colours.palette.on_surface, 0.8)

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
        onEntered: root.hovered = true
        onExited: root.hovered = false
        onClicked: root.toRun()
    }

    Behavior on color {
        PropertyAnimation {
            duration: Config.settings.animationSpeed
            easing.type: Easing.InSine
        }

    }

    Behavior on Layout.preferredWidth {
        PropertyAnimation {
            duration: Config.settings.animationSpeed
            easing.type: Easing.InSine
        }

    }

}
