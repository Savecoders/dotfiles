import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.core
import qs.services

Rectangle {
    id: root

    property bool isVertical: false

    color: "transparent"
    implicitWidth: isVertical ? 24 : (contentRow.implicitWidth + 4)
    implicitHeight: isVertical ? 24 : 24
    ToolTip.visible: mouseArea.containsMouse
    ToolTip.delay: 200
    ToolTip.text: Ram.usedStr && Ram.totalStr ? ("RAM: " + Ram.usedStr + " / " + Ram.totalStr + " (" + Ram.usage + "%)") : ("RAM: " + Ram.usage + "%")

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
    }

    RowLayout {
        id: contentRow

        anchors.centerIn: parent
        spacing: 6

        CircularProgressIcon {
            width: 22
            height: 22
            strokeWidth: 2
            iconPixelSize: 11
            value: Ram.usage / 100
            icon: "memory_alt"
            fgColor: Colours.palette.primary
        }

        Text {
            visible: !root.isVertical
            text: Ram.usage + "%"
            font.family: Config.settings.font
            font.pixelSize: 13
            font.weight: 600
            color: Colours.palette.on_surface
        }

    }

}
