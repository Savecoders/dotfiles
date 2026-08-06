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
    property bool showBattery: true
    property bool showBatteryPercentage: true
    property int iconPixelSize: isVertical ? 16 : 14

    columns: isVertical ? 1 : 6
    rows: isVertical ? 5 : 1
    columnSpacing: isVertical ? 0 : 8
    rowSpacing: isVertical ? 8 : 0

    // date
    Text {
        visible: root.showClock
        text: isVertical ? (Time.hour + "\n" + Time.minute) : Time.time
        font.family: Config.settings.font
        font.pixelSize: 11
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

    // 4. Battery Component
    Item {
        visible: root.showBattery
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        implicitWidth: (root.showBatteryPercentage && !root.isVertical) ? batteryCapsule.width : batteryOnlyIcon.width
        implicitHeight: (root.showBatteryPercentage && !root.isVertical) ? batteryCapsule.height : batteryOnlyIcon.height

        // Icon only (used in Vertical mode or when showBatteryPercentage is false)
        BatteryWidget {
            id: batteryOnlyIcon

            visible: !root.showBatteryPercentage || root.isVertical
            anchors.centerIn: parent
            font.family: Config.settings.iconFont
            font.pixelSize: root.iconPixelSize
            color: root.contentColor

            Behavior on color {
                PropertyAnimation {
                    duration: Config.settings.animationSpeed
                    easing.type: Easing.InSine
                }

            }

        }

        // Pill Capsule background (used in Horizontal mode when showBatteryPercentage is true)
        Rectangle {
            id: batteryCapsule

            visible: root.showBatteryPercentage && !root.isVertical
            width: batteryCapsuleRow.implicitWidth + 14
            height: 24
            radius: Config.settings.borderRadius ? Math.min(12, Config.settings.borderRadius) : 12
            color: Qt.alpha(root.contentColor, 0.15)
            anchors.centerIn: parent

            Row {
                id: batteryCapsuleRow

                anchors.centerIn: parent
                spacing: 4

                BatteryWidget {
                    font.family: Config.settings.iconFont
                    font.pixelSize: 13
                    color: root.contentColor
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: (Battery.percent !== undefined ? Battery.percent : (Battery.batteryPercentage !== undefined ? Battery.batteryPercentage : 100)) + "%"
                    font.family: Config.settings.font
                    font.pixelSize: 11
                    font.weight: 700
                    color: root.contentColor
                    anchors.verticalCenter: parent.verticalCenter
                }

            }

        }

    }

}
