import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.core
import qs.features.common
import qs.services

Item {
    id: root

    readonly property int availWidth: Math.max(380, (parent ? parent.width : 515) - 40)
    readonly property int cardW: Math.floor((availWidth - 20) / 3)
    readonly property int cardWLast: (availWidth - 20) - (cardW * 2)

    Layout.fillWidth: true
    Layout.leftMargin: 20
    Layout.rightMargin: 20
    Layout.preferredHeight: 140
    implicitHeight: 140

    RowLayout {
        anchors.fill: parent
        spacing: 10

        // 1. CPU Card
        Rectangle {
            id: cpuCard

            property bool hovered: false

            Layout.preferredWidth: root.cardW
            Layout.fillHeight: true
            radius: Math.max(8, Config.settings.borderRadius - 2)
            color: cpuCard.hovered ? Colours.palette.surface_container_high : Colours.palette.surface_container
            border.color: Qt.alpha(Colours.palette.outline, 0.15)
            border.width: 1

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: cpuCard.hovered = true
                onExited: cpuCard.hovered = false
            }

            CircularProgressIcon {
                anchors.centerIn: parent
                Layout.preferredWidth: 84
                Layout.preferredHeight: 84
                implicitWidth: 84
                implicitHeight: 84
                strokeWidth: 5
                iconPixelSize: 20
                subTextPixelSize: 11
                value: Cpu.usage / 100
                icon: "developer_board"
                subText: Cpu.usage + "%"
                fgColor: Colours.palette.primary
                subTextColor: Colours.palette.on_surface
                bgColor: Qt.alpha(Colours.palette.outline, 0.25)
                innerCircleColor: Qt.alpha(Colours.palette.surface_container_highest, 0.6)
            }

        }

        // 2. RAM Card
        Rectangle {
            id: ramCard

            property bool hovered: false

            Layout.preferredWidth: root.cardW
            Layout.fillHeight: true
            radius: Math.max(8, Config.settings.borderRadius - 2)
            color: ramCard.hovered ? Colours.palette.surface_container_high : Colours.palette.surface_container
            border.color: Qt.alpha(Colours.palette.outline, 0.15)
            border.width: 1

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: ramCard.hovered = true
                onExited: ramCard.hovered = false
            }

            CircularProgressIcon {
                anchors.centerIn: parent
                Layout.preferredWidth: 84
                Layout.preferredHeight: 84
                implicitWidth: 84
                implicitHeight: 84
                strokeWidth: 5
                iconPixelSize: 20
                subTextPixelSize: 11
                value: Ram.usage / 100
                icon: "memory_alt"
                subText: Ram.usage + "%"
                fgColor: Colours.palette.primary
                subTextColor: Colours.palette.on_surface
                bgColor: Qt.alpha(Colours.palette.outline, 0.25)
                innerCircleColor: Qt.alpha(Colours.palette.surface_container_highest, 0.6)
            }

        }

        // 3. Temp Card
        Rectangle {
            id: tempCard

            property bool hovered: false

            Layout.preferredWidth: root.cardWLast
            Layout.fillHeight: true
            radius: Math.max(8, Config.settings.borderRadius - 2)
            color: tempCard.hovered ? Colours.palette.surface_container_high : Colours.palette.surface_container
            border.color: Qt.alpha(Colours.palette.outline, 0.15)
            border.width: 1

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: tempCard.hovered = true
                onExited: tempCard.hovered = false
            }

            CircularProgressIcon {
                anchors.centerIn: parent
                Layout.preferredWidth: 84
                Layout.preferredHeight: 84
                implicitWidth: 84
                implicitHeight: 84
                strokeWidth: 5
                iconPixelSize: 20
                subTextPixelSize: 11
                value: Math.max(0, Math.min(1, (Thermal.temp - 25) / (90 - 25)))
                icon: "device_thermostat"
                subText: Thermal.temp + "°C"
                fgColor: Thermal.temp > 75 ? Colours.palette.error : Colours.palette.primary
                subTextColor: Thermal.temp > 75 ? Colours.palette.error : Colours.palette.on_surface
                bgColor: Qt.alpha(Colours.palette.outline, 0.25)
                innerCircleColor: Qt.alpha(Colours.palette.surface_container_highest, 0.6)
            }

        }

    }

}
