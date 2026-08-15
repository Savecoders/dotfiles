import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.core
import qs.services

StyledRect {
    id: root

    property bool isVertical: false
    property string tooltipText: ""
    property real progressValue: 0
    property string iconName: ""
    property string labelText: ""
    property color fgColor: Colours.palette.primary

    variant: "transparent"
    color: "transparent"
    implicitWidth: isVertical ? 32 : (contentRow.implicitWidth + 4)
    implicitHeight: 32
    ToolTip.visible: mouseArea.containsMouse
    ToolTip.delay: 200
    ToolTip.text: root.tooltipText

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
    }

    RowLayout {
        id: contentRow

        anchors.centerIn: parent
        spacing: Styling.spacing.md

        CircularProgressIcon {
            width: 22
            height: 22
            strokeWidth: 2
            iconPixelSize: Styling.fontSize.sm
            value: root.progressValue
            icon: root.iconName
            fgColor: root.fgColor
        }

        Text {
            visible: !root.isVertical
            text: root.labelText
            font.family: (Config.settings && Config.settings.font) ? Config.settings.font : "SF Pro Display"
            font.pixelSize: Styling.fontSize.body
            font.weight: 600
            color: Colours.palette.on_surface
        }

    }

}
