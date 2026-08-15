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

    readonly property int availWidth: root.width > 0 ? root.width : 475
    readonly property int cardW: Math.floor((availWidth - 20) / 3)
    readonly property int cardWLast: (availWidth - 20) - (cardW * 2)

    Layout.fillWidth: true
    Layout.leftMargin: 20
    Layout.rightMargin: 20
    Layout.preferredHeight: 140
    implicitHeight: 140

    RowLayout {
        anchors.fill: parent
        spacing: Styling.spacing.xl

        // 1. CPU Card
        StyledRect {
            id: cpuCard

            property bool hovered: false

            variant: "common"
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Math.max(8, ((Config.settings && Config.settings.borderRadius !== undefined) ? Config.settings.borderRadius : 8) - 2)
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
                iconPixelSize: Styling.fontSize.headline
                subTextPixelSize: Styling.fontSize.sm
                value: (Cpu.usage || 0) / 100
                icon: "developer_board"
                subText: (Cpu.usage || 0) + "%"
                fgColor: Colours.palette.primary
                subTextColor: Colours.palette.on_surface
                bgColor: Qt.alpha(Colours.palette.outline, 0.25)
                innerCircleColor: Qt.alpha(Colours.palette.surface_container_highest, 0.6)
            }

        }

        // 2. RAM Card
        StyledRect {
            id: ramCard

            property bool hovered: false

            variant: "common"
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Math.max(8, ((Config.settings && Config.settings.borderRadius !== undefined) ? Config.settings.borderRadius : 8) - 2)
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
                iconPixelSize: Styling.fontSize.headline
                subTextPixelSize: Styling.fontSize.sm
                value: (Ram.usage || 0) / 100
                icon: "memory_alt"
                subText: (Ram.usage || 0) + "%"
                fgColor: Colours.palette.primary
                subTextColor: Colours.palette.on_surface
                bgColor: Qt.alpha(Colours.palette.outline, 0.25)
                innerCircleColor: Qt.alpha(Colours.palette.surface_container_highest, 0.6)
            }

        }

        // 3. Temp Card
        StyledRect {
            id: tempCard

            property bool hovered: false

            variant: "common"
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Math.max(8, ((Config.settings && Config.settings.borderRadius !== undefined) ? Config.settings.borderRadius : 8) - 2)
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
                iconPixelSize: Styling.fontSize.headline
                subTextPixelSize: Styling.fontSize.sm
                value: Math.max(0, Math.min(1, (((Thermal.temp || 25) - 25) / (90 - 25))))
                icon: "device_thermostat"
                subText: (Thermal.temp || 0) + "°C"
                fgColor: (Thermal.temp || 0) > 75 ? Colours.palette.error : Colours.palette.primary
                subTextColor: (Thermal.temp || 0) > 75 ? Colours.palette.error : Colours.palette.on_surface
                bgColor: Qt.alpha(Colours.palette.outline, 0.25)
                innerCircleColor: Qt.alpha(Colours.palette.surface_container_highest, 0.6)
            }

        }

    }

}
