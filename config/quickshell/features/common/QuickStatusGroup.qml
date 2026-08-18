import QtQuick
import QtQuick.Layouts
import qs.core
import qs.features.common
import qs.services

GridLayout {
    id: root

    property bool isVertical: false
    property color contentColor: Colours.palette.on_surface
    property bool showClock: true
    property bool showNetwork: true
    property bool showBluetooth: true
    property int iconPixelSize: isVertical ? Styling.fontSize.lg : Styling.fontSize.bodyLarge

    columns: isVertical ? 1 : 3
    rows: isVertical ? 3 : 1
    columnSpacing: isVertical ? Styling.spacing.none : Styling.spacing.lg
    rowSpacing: isVertical ? Styling.spacing.lg : Styling.spacing.none

    Text {
        visible: root.showClock
        text: isVertical ? (Time.hour + "\n" + Time.minute) : Time.time
        font.family: Config.settings.font
        font.pixelSize: Styling.fontSize.sm
        font.weight: 500
        lineHeight: 0.9
        color: root.contentColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        Behavior on color {
            PropertyAnimation {
                duration: Config.settings.animationSpeed
                easing.type: Easing.InSine
            }

        }

    }

    // 2. Network Icon
    Text {
        visible: root.showNetwork
        text: Network.getIcon()
        font.family: Config.settings.iconFont
        font.pixelSize: root.iconPixelSize
        color: Network.getBool() ? root.contentColor : Qt.alpha(root.contentColor, 0.4)
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        Behavior on color {
            PropertyAnimation {
                duration: Config.settings.animationSpeed
                easing.type: Easing.InSine
            }

        }

    }

    // 3. Bluetooth Icon (shows ONLY when Bluetooth is ON)
    Text {
        visible: root.showBluetooth && Bluetooth.getBool()
        text: Bluetooth.getIcon()
        font.family: Config.settings.iconFont
        font.pixelSize: root.iconPixelSize
        color: Bluetooth.getBool() ? root.contentColor : Qt.alpha(root.contentColor, 0.4)
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        Behavior on color {
            PropertyAnimation {
                duration: Config.settings.animationSpeed
                easing.type: Easing.InSine
            }

        }

    }

}
