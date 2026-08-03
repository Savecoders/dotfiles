import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.core
import qs.features

Rectangle {
    id: root

    property bool hovered: false
    property bool selected: false

    width: parent.width
    height: 50
    color: {
        if (selected || hovered)
            return Colours.palette.surface_container_high;
        else
            return Colours.palette.surface;
    }
    radius: Config.settings.borderRadius

    ClippingWrapperRectangle {
        id: entryIcon

        property int size: 25

        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.top: parent.top
        anchors.topMargin: (parent.height / 2) - (size / 2)
        height: size
        width: size
        radius: 1000
        color: "transparent"

        child: Image {
            source: Quickshell.iconPath(modelData.icon, "application-x-executable")
            sourceSize: Qt.size(entryIcon.size, entryIcon.size)
            asynchronous: true
            cache: true
            layer.enabled: Config.settings.colours.genType == "scheme-monochrome" && !Config.settings.colours.useCustom

            layer.effect: MultiEffect {
                saturation: -1
            }

        }

    }

    ColumnLayout {
        anchors.left: entryIcon.right
        anchors.leftMargin: 10
        anchors.top: parent.top
        anchors.topMargin: (parent.height / 2) - (height / 2)
        height: 40
        spacing: -5

        Text {
            font.family: Config.settings.font
            font.weight: 400
            text: modelData.name
            font.pixelSize: 14
            color: {
                if (root.hovered || root.selected)
                    return Colours.palette.on_surface;
                else
                    return Colours.palette.outline;
            }

            Behavior on color {
                PropertyAnimation {
                    duration: 200
                    easing.type: Easing.InSine
                }

            }

        }

        Text {
            font.family: Config.settings.font
            font.weight: 400
            text: modelData.comment
            font.pixelSize: 12
            color: {
                if (root.hovered || root.selected)
                    return Qt.alpha(Colours.palette.on_surface, 0.7);
                else
                    return Qt.alpha(Colours.palette.outline, 0.7);
            }

            Behavior on color {
                PropertyAnimation {
                    duration: 200
                    easing.type: Easing.InSine
                }

            }

        }

    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered = true
        onExited: root.hovered = false
        onClicked: {
            modelData.execute();
            IPCLoader.toggleLauncher();
        }
    }

    Behavior on color {
        PropertyAnimation {
            duration: 200
            easing.type: Easing.InSine
        }

    }

}
