import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.core
import qs.features.settings
import qs.features.settings.content

RowLayout {
    id: root

    spacing: Styling.spacing.xxl
    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
    Layout.preferredWidth: pageWrapper.width
    Layout.preferredHeight: 120

    Text {
        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
        text: "vertical_align_bottom"
        font.family: Config.settings.iconFont
        font.pixelSize: 20
        color: Qt.alpha(Colours.palette.on_surface, 0.75)
    }

    Text {
        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
        Layout.fillWidth: true
        text: "Notification Position"
        font.family: Config.settings.font
        font.pixelSize: Styling.fontSize.md
        color: Qt.alpha(Colours.palette.on_surface, 0.9)
    }

    StyledRect {
        id: screenRect

        variant: "internalbg"
        useDefaultRadius: false
        customRadius: Math.max(4, Config.settings.borderRadius - 12)
        radius: customRadius
        Layout.fillWidth: true
        Layout.preferredHeight: 112
        border.color: Colours.palette.outline_variant
        border.width: 1

        StyledRect {
            id: topLeftSpot

            readonly property string posValue: "top-left"
            readonly property bool isActive: (Config.settings.notifications ? Config.settings.notifications.position : "top-right") === posValue
            property bool hovered: false

            variant: "common"
            useDefaultRadius: false
            customRadius: 6
            radius: 6
            width: 24
            height: 24
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 10

            color: isActive ? Colours.palette.primary : (hovered ? Colours.palette.surface_container_high : Colours.palette.surface_container)
            border.color: isActive ? Colours.palette.primary : (hovered ? Colours.palette.outline : Colours.palette.outline_variant)
            border.width: isActive ? 2 : 1

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: topLeftSpot.hovered = true
                onExited: topLeftSpot.hovered = false
                onClicked: Config.updateKey("notifications.position", topLeftSpot.posValue)
            }

            Behavior on color {
                PropertyAnimation {
                    duration: 150
                    easing.type: Easing.InSine
                }
            }

            Behavior on border.color {
                PropertyAnimation {
                    duration: 150
                    easing.type: Easing.InSine
                }
            }
        }

        StyledRect {
            id: topCenterSpot

            readonly property string posValue: "top-center"
            readonly property bool isActive: (Config.settings.notifications ? Config.settings.notifications.position : "top-right") === posValue
            property bool hovered: false

            variant: "common"
            useDefaultRadius: false
            customRadius: 6
            radius: 6
            width: 24
            height: 24
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: 10

            color: isActive ? Colours.palette.primary : (hovered ? Colours.palette.surface_container_high : Colours.palette.surface_container)
            border.color: isActive ? Colours.palette.primary : (hovered ? Colours.palette.outline : Colours.palette.outline_variant)
            border.width: isActive ? 2 : 1

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: topCenterSpot.hovered = true
                onExited: topCenterSpot.hovered = false
                onClicked: Config.updateKey("notifications.position", topCenterSpot.posValue)
            }

            Behavior on color {
                PropertyAnimation {
                    duration: 150
                    easing.type: Easing.InSine
                }
            }

            Behavior on border.color {
                PropertyAnimation {
                    duration: 150
                    easing.type: Easing.InSine
                }
            }
        }

        StyledRect {
            id: topRightSpot

            readonly property string posValue: "top-right"
            readonly property bool isActive: (Config.settings.notifications ? Config.settings.notifications.position : "top-right") === posValue
            property bool hovered: false

            variant: "common"
            useDefaultRadius: false
            customRadius: 6
            radius: 6
            width: 24
            height: 24
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 10

            color: isActive ? Colours.palette.primary : (hovered ? Colours.palette.surface_container_high : Colours.palette.surface_container)
            border.color: isActive ? Colours.palette.primary : (hovered ? Colours.palette.outline : Colours.palette.outline_variant)
            border.width: isActive ? 2 : 1

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: topRightSpot.hovered = true
                onExited: topRightSpot.hovered = false
                onClicked: Config.updateKey("notifications.position", topRightSpot.posValue)
            }

            Behavior on color {
                PropertyAnimation {
                    duration: 150
                    easing.type: Easing.InSine
                }
            }

            Behavior on border.color {
                PropertyAnimation {
                    duration: 150
                    easing.type: Easing.InSine
                }
            }
        }

        StyledRect {
            id: bottomLeftSpot

            readonly property string posValue: "bottom-left"
            readonly property bool isActive: (Config.settings.notifications ? Config.settings.notifications.position : "top-right") === posValue
            property bool hovered: false

            variant: "common"
            useDefaultRadius: false
            customRadius: 6
            radius: 6
            width: 24
            height: 24
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.margins: 10

            color: isActive ? Colours.palette.primary : (hovered ? Colours.palette.surface_container_high : Colours.palette.surface_container)
            border.color: isActive ? Colours.palette.primary : (hovered ? Colours.palette.outline : Colours.palette.outline_variant)
            border.width: isActive ? 2 : 1

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: bottomLeftSpot.hovered = true
                onExited: bottomLeftSpot.hovered = false
                onClicked: Config.updateKey("notifications.position", bottomLeftSpot.posValue)
            }

            Behavior on color {
                PropertyAnimation {
                    duration: 150
                    easing.type: Easing.InSine
                }
            }

            Behavior on border.color {
                PropertyAnimation {
                    duration: 150
                    easing.type: Easing.InSine
                }
            }
        }

        StyledRect {
            id: bottomCenterSpot

            readonly property string posValue: "bottom-center"
            readonly property bool isActive: (Config.settings.notifications ? Config.settings.notifications.position : "top-right") === posValue
            property bool hovered: false

            variant: "common"
            useDefaultRadius: false
            customRadius: 6
            radius: 6
            width: 24
            height: 24
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: 10

            color: isActive ? Colours.palette.primary : (hovered ? Colours.palette.surface_container_high : Colours.palette.surface_container)
            border.color: isActive ? Colours.palette.primary : (hovered ? Colours.palette.outline : Colours.palette.outline_variant)
            border.width: isActive ? 2 : 1

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: bottomCenterSpot.hovered = true
                onExited: bottomCenterSpot.hovered = false
                onClicked: Config.updateKey("notifications.position", bottomCenterSpot.posValue)
            }

            Behavior on color {
                PropertyAnimation {
                    duration: 150
                    easing.type: Easing.InSine
                }
            }

            Behavior on border.color {
                PropertyAnimation {
                    duration: 150
                    easing.type: Easing.InSine
                }
            }
        }

        StyledRect {
            id: bottomRightSpot

            readonly property string posValue: "bottom-right"
            readonly property bool isActive: (Config.settings.notifications ? Config.settings.notifications.position : "top-right") === posValue
            property bool hovered: false

            variant: "common"
            useDefaultRadius: false
            customRadius: 6
            radius: 6
            width: 24
            height: 24
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 10

            color: isActive ? Colours.palette.primary : (hovered ? Colours.palette.surface_container_high : Colours.palette.surface_container)
            border.color: isActive ? Colours.palette.primary : (hovered ? Colours.palette.outline : Colours.palette.outline_variant)
            border.width: isActive ? 2 : 1

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: bottomRightSpot.hovered = true
                onExited: bottomRightSpot.hovered = false
                onClicked: Config.updateKey("notifications.position", bottomRightSpot.posValue)
            }

            Behavior on color {
                PropertyAnimation {
                    duration: 150
                    easing.type: Easing.InSine
                }
            }

            Behavior on border.color {
                PropertyAnimation {
                    duration: 150
                    easing.type: Easing.InSine
                }
            }
        }
    }
}
