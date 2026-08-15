import QtQuick
import Quickshell
import Quickshell.Io
import qs.core

Item {
    id: root

    property string text: "Placeholder"
    property string iconCode: "settings"
    property int iconSize: 23

    implicitHeight: 25
    implicitWidth: childrenRect.width

    Text {
        id: icon

        text: root.iconCode
        font.family: Config.settings.iconFont
        font.pixelSize: root.iconSize
        color: Colours.palette.on_surface
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        anchors.left: icon.right
        anchors.leftMargin: Styling.spacing.xl
        anchors.verticalCenter: parent.verticalCenter
        text: root.text
        font.family: Config.settings.font
        font.pixelSize: Styling.fontSize.headline
        color: Colours.palette.on_surface
    }

}
