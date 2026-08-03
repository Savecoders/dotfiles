import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.core
import qs.services

Rectangle {
    id: root

    property bool isVertical: false

    color: "transparent"
    implicitWidth: isVertical ? 32 : (contentRow.implicitWidth + 4)
    implicitHeight: 32
    ToolTip.visible: mouseArea.containsMouse
    ToolTip.delay: 200
    ToolTip.text: "Package Temp: " + Thermal.temp + "°C"

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
            value: Math.max(0, Math.min(1, (Thermal.temp - 25) / (90 - 25)))
            icon: "device_thermostat"
            fgColor: Thermal.temp > 75 ? Colours.palette.error : Colours.palette.primary
        }

        Text {
            visible: !root.isVertical
            text: Thermal.temp + "°C"
            font.family: Config.settings.font
            font.pixelSize: 13
            font.weight: 600
            color: Colours.palette.on_surface
        }

    }

}
