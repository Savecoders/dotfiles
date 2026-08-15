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

    property bool isToggled: false
    property int rWidth
    property int rHeight
    property var toRun

    variant: "internalbg"
    useDefaultRadius: false
    Layout.preferredWidth: rWidth
    Layout.preferredHeight: rHeight
    color: Colours.palette.surface_container
    border.width: 1
    border.color: isToggled ? "transparent" : Qt.alpha(Colours.palette.outline, 0.5)
    radius: Config.settings.borderRadius + 15

    StyledRect {
        variant: "internalbg"
        useDefaultRadius: false
        border.width: 0
        width: parent.rWidth - 5
        height: parent.rHeight - 5
        anchors.top: parent.top
        anchors.topMargin: (parent.rHeight / 2) - (height / 2)
        anchors.left: parent.left
        anchors.leftMargin: (parent.rWidth / 2) - (width / 2)
        radius: parent.radius
        color: root.isToggled ? Colours.palette.primary : Colours.palette.surface_container

        StyledRect {
            variant: "focus"
            useDefaultRadius: false
            border.width: 0
            width: parent.height - 7
            height: width
            color: root.isToggled ? Colours.palette.on_primary : Colours.palette.on_surface
            anchors.top: parent.top
            anchors.topMargin: (parent.height / 2) - (height / 2)
            anchors.left: parent.left
            anchors.leftMargin: root.isToggled ? parent.width - width - 4 : 4
            topLeftRadius: root.isToggled ? 5 : parent.radius
            bottomLeftRadius: root.isToggled ? 5 : parent.radius
            topRightRadius: root.isToggled ? parent.radius : 5
            bottomRightRadius: root.isToggled ? parent.radius : 5

            Behavior on topLeftRadius {
                PropertyAnimation {
                    duration: Config.settings.animationSpeed
                    easing.type: Easing.InSine
                }

            }

            Behavior on bottomLeftRadius {
                PropertyAnimation {
                    duration: Config.settings.animationSpeed
                    easing.type: Easing.InSine
                }

            }

            Behavior on topRightRadius {
                PropertyAnimation {
                    duration: Config.settings.animationSpeed
                    easing.type: Easing.InSine
                }

            }

            Behavior on bottomRightRadius {
                PropertyAnimation {
                    duration: Config.settings.animationSpeed
                    easing.type: Easing.InSine
                }

            }

            Behavior on color {
                PropertyAnimation {
                    duration: Config.settings.animationSpeed
                    easing.type: Easing.InSine
                }

            }

            Behavior on anchors.leftMargin {
                PropertyAnimation {
                    duration: Config.settings.animationSpeed
                    easing.type: Easing.InSine
                }

            }

        }

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
        onClicked: parent.toRun()
    }

}
