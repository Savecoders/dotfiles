import QtQuick
import QtQuick.Layouts
import qs.core

StyledRect {
    id: root

    property bool isToggled: false
    property string text: ""
    property string icon: ""
    property real iconSize: Styling.fontSize.lg
    property real textSize: Styling.fontSize.body
    property bool hovered: mouseArea.containsMouse

    signal toggled(bool newState)

    variant: "internalbg"
    useDefaultRadius: true
    Layout.fillWidth: true
    Layout.preferredHeight: 36
    color: hovered ? Colours.palette.surface_container_high : "transparent"
    border.width: 0

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Styling.spacing.sm
        anchors.rightMargin: Styling.spacing.sm
        spacing: Styling.spacing.md

        Text {
            visible: root.icon !== ""
            text: root.icon
            font.family: Config.settings.iconFont
            font.pixelSize: root.iconSize
            color: root.isToggled ? Colours.palette.primary : Colours.palette.on_surface_variant
            Layout.alignment: Qt.AlignVCenter

            Behavior on color {
                PropertyAnimation {
                    duration: Config.settings.animationSpeed ?? 150
                    easing.type: Easing.OutQuad
                }

            }

        }

        Text {
            Layout.fillWidth: true
            text: root.text
            font.family: Config.settings.font
            font.pixelSize: root.textSize
            font.weight: Font.Medium
            color: Colours.palette.on_surface
            Layout.alignment: Qt.AlignVCenter
        }

        // Slice Toggle Pill Track
        StyledRect {
            id: track

            width: 44
            height: 22
            radius: 11
            useDefaultRadius: false
            border.width: 1
            border.color: root.isToggled ? Colours.palette.primary : Colours.palette.outline_variant
            color: root.isToggled ? Colours.palette.primary : Colours.palette.surface_container
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

            // Sliding Thumb
            StyledRect {
                id: thumb

                width: 16
                height: 16
                radius: 8
                useDefaultRadius: false
                border.width: 0
                color: root.isToggled ? Colours.palette.on_primary : Colours.palette.on_surface_variant
                anchors.verticalCenter: parent.verticalCenter
                x: root.isToggled ? (track.width - width - 3) : 3

                Behavior on x {
                    NumberAnimation {
                        duration: Config.settings.animationSpeed ?? 150
                        easing.type: Easing.OutCubic
                    }

                }

                Behavior on color {
                    PropertyAnimation {
                        duration: Config.settings.animationSpeed ?? 150
                        easing.type: Easing.OutQuad
                    }

                }

            }

            Behavior on color {
                PropertyAnimation {
                    duration: Config.settings.animationSpeed ?? 150
                    easing.type: Easing.OutQuad
                }

            }

            Behavior on border.color {
                PropertyAnimation {
                    duration: Config.settings.animationSpeed ?? 150
                    easing.type: Easing.OutQuad
                }

            }

        }

    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.isToggled = !root.isToggled;
            root.toggled(root.isToggled);
        }
    }

    Behavior on color {
        PropertyAnimation {
            duration: Config.settings.animationSpeed ?? 150
            easing.type: Easing.OutQuad
        }

    }

}
