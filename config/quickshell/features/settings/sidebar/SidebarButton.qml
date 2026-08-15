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
    property bool collapsed: false
    required property int number
    required property int selected
    property int rWidth
    property int rHeight
    property var toRun
    property string bgColour: "transparent"
    property string colour: Colours.palette.on_surface
    property string bgColourHovered: Colours.palette.surface_container_highest
    property string colourHovered: Colours.palette.on_surface
    property string bigText: "Placeholder"
    property int bigTextSize: Styling.fontSize.bodyLarge
    property string iconCode: "settings"
    property real iconSize: Styling.fontSize.xl

    variant: (root.selected == root.number) ? "focus" : "internalbg"
    useDefaultRadius: false
    Layout.preferredWidth: root.collapsed ? 40 : rWidth
    Layout.preferredHeight: rHeight
    Layout.alignment: root.collapsed ? Qt.AlignHCenter : Qt.AlignLeft
    color: {
        if (root.selected == root.number)
            return Colours.palette.primary;
        else if (isHovered)
            return bgColourHovered;
        else
            return bgColour;
    }
    radius: root.collapsed ? 20 : Math.max(6, Config.settings.borderRadius - 8)

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: root.collapsed ? 0 : Styling.spacing.xxl
        anchors.rightMargin: root.collapsed ? 0 : Styling.spacing.xxl
        spacing: Styling.spacing.xl

        Item {
            Layout.alignment: root.collapsed ? Qt.AlignHCenter | Qt.AlignVCenter : Qt.AlignLeft | Qt.AlignVCenter
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28

            Text {
                anchors.centerIn: parent
                text: iconCode
                font.family: Config.settings.iconFont
                font.pixelSize: root.iconSize
                font.weight: 500
                color: {
                    if (root.selected == root.number)
                        return Colours.palette.on_primary;
                    else if (root.isHovered)
                        return root.colourHovered;
                    else
                        return root.colour;
                }

                Behavior on color {
                    PropertyAnimation {
                        duration: Config.settings.animationSpeed
                        easing.type: Easing.InSine
                    }

                }

            }

        }

        Text {
            visible: !root.collapsed
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            Layout.fillWidth: true
            text: bigText
            font.family: Config.settings.font
            font.pixelSize: bigTextSize
            font.weight: root.selected == root.number ? 600 : 500
            elide: Text.ElideRight
            color: {
                if (root.selected == root.number)
                    return Colours.palette.on_primary;
                else if (root.isHovered)
                    return root.colourHovered;
                else
                    return root.colour;
            }

            Behavior on color {
                PropertyAnimation {
                    duration: Config.settings.animationSpeed
                    easing.type: Easing.InSine
                }

            }

        }

    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: parent.isHovered = true
        onExited: parent.isHovered = false
        onClicked: parent.toRun()
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
