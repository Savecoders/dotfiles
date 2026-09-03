import QtQuick
import QtQuick.Layouts
import qs.core
import qs.features
import qs.services

StyledRect {
    id: root

    property bool isVertical: false
    readonly property int batPercent: (Power.percent !== undefined) ? Power.percent : 100
    readonly property bool isCharging: !!Power.charging
    readonly property string tooltipText: "Battery: " + root.batPercent + "% (" + (root.isCharging ? (root.batPercent === 100 ? "Full" : "Charging") : "Discharging") + ")" + (Power.powerDrawWatts > 0 ? (" • " + Power.powerDrawWatts + " W") : "") + " • " + Power.activeProfile
    readonly property color fgColor: {
        if (root.isCharging)
            return Accents.green;

        if (root.batPercent <= 20)
            return Colours.palette.error;

        return Colours.palette.primary;
    }

    variant: "transparent"
    color: "transparent"
    implicitWidth: isVertical ? Styling.fontSize.display : (contentLayout.implicitWidth + Styling.spacing.lg)
    implicitHeight: isVertical ? (Styling.fontSize.display + Styling.spacing.sm) : Styling.fontSize.display
    Component.onDestruction: Tooltip.hide()

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: {
            if (root.tooltipText !== "")
                Tooltip.showItem(root, root.tooltipText);

        }
        onExited: Tooltip.hide()
        onClicked: {
            Tooltip.hide();
            IPCLoader.toggleBatteryAt(root);
        }
    }

    GridLayout {
        id: contentLayout

        anchors.centerIn: parent
        columns: root.isVertical ? 1 : 2
        rows: root.isVertical ? 2 : 1
        columnSpacing: root.isVertical ? Styling.spacing.none : Styling.spacing.sm
        rowSpacing: root.isVertical ? Styling.spacing.xs : Styling.spacing.none

        Text {
            id: iconText

            text: Power.getBatteryIcon()
            font.family: Config.settings.iconFont
            font.pixelSize: root.isVertical ? Styling.fontSize.title : Styling.fontSize.lg
            color: root.fgColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            Behavior on color {
                PropertyAnimation {
                    duration: Config.settings.animationSpeed ?? 150
                    easing.type: Easing.InSine
                }

            }

        }

        Text {
            id: percentText

            text: root.batPercent + "%"
            font.family: Config.get("font", "SF Pro Display")
            font.pixelSize: root.isVertical ? Styling.fontSize.caption : Styling.fontSize.body
            font.weight: 600
            color: mouseArea.containsMouse ? Colours.palette.primary : Colours.palette.on_surface
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            Behavior on color {
                PropertyAnimation {
                    duration: Config.settings.animationSpeed ?? 150
                    easing.type: Easing.InSine
                }

            }

        }

    }

}
