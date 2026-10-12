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
    property bool showKeepAwake: false
    property bool showNightmode: false
    property bool showDnd: false
    property bool onlyActiveNetwork: false
    property bool showFallback: false
    property int iconPixelSize: isVertical ? Styling.fontSize.lg : Styling.fontSize.bodyLarge
    readonly property bool hasActiveIndicator: (showClock) || (showNetwork && (onlyActiveNetwork ? Network.getBool() : true)) || (showBluetooth && (BluetoothService.bluetoothEnabled || Bluetooth.getBool())) || (showKeepAwake && Idle.keepAwake) || (showNightmode && Nightmode.isNightmodeOn) || (showDnd && Notifications.popupInhibited)

    columns: isVertical ? 1 : -1
    rows: isVertical ? -1 : 1
    columnSpacing: isVertical ? Styling.spacing.none : Styling.spacing.md
    rowSpacing: isVertical ? Styling.spacing.md : Styling.spacing.none

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
        visible: root.showNetwork && (root.onlyActiveNetwork ? Network.getBool() : true)
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

    // 3. Bluetooth Icon (shows when Bluetooth adapter is enabled)
    Text {
        visible: root.showBluetooth && (BluetoothService.bluetoothEnabled || Bluetooth.getBool())
        text: Bluetooth.getIcon()
        font.family: Config.settings.iconFont
        font.pixelSize: root.iconPixelSize
        color: (BluetoothService.bluetoothEnabled || Bluetooth.getBool()) ? root.contentColor : Qt.alpha(root.contentColor, 0.4)
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        Behavior on color {
            PropertyAnimation {
                duration: Config.settings.animationSpeed
                easing.type: Easing.InSine
            }

        }

    }

    // 4. Keep Awake Icon
    Text {
        visible: root.showKeepAwake && Idle.keepAwake
        text: "coffee"
        font.family: Config.settings.iconFont
        font.pixelSize: root.iconPixelSize
        color: root.contentColor
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        Behavior on color {
            PropertyAnimation {
                duration: Config.settings.animationSpeed
                easing.type: Easing.InSine
            }

        }

    }

    // 5. Nightmode Icon
    Text {
        visible: root.showNightmode && Nightmode.isNightmodeOn
        text: "bedtime"
        font.family: Config.settings.iconFont
        font.pixelSize: root.iconPixelSize
        color: root.contentColor
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        Behavior on color {
            PropertyAnimation {
                duration: Config.settings.animationSpeed
                easing.type: Easing.InSine
            }

        }

    }

    // 6. Do Not Disturb Icon
    Text {
        visible: root.showDnd && Notifications.popupInhibited
        text: "do_not_disturb_on"
        font.family: Config.settings.iconFont
        font.pixelSize: root.iconPixelSize
        color: root.contentColor
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        Behavior on color {
            PropertyAnimation {
                duration: Config.settings.animationSpeed
                easing.type: Easing.InSine
            }

        }

    }

    // 7. Fallback Icon for all-off state (Dashboard / Tune icon)
    Text {
        visible: root.showFallback && !root.hasActiveIndicator
        text: "tune"
        font.family: Config.settings.iconFont
        font.pixelSize: root.iconPixelSize
        color: root.contentColor
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        Behavior on color {
            PropertyAnimation {
                duration: Config.settings.animationSpeed
                easing.type: Easing.InSine
            }

        }

    }

}
