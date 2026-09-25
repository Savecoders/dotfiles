import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.core
import qs.features
import qs.features.common
import qs.features.dashboard
import qs.features.dashboard.toggles
import qs.services

Item {
    id: root

    property int rowHeight: 102
    property int spacing: Styling.spacing.xxl
    property int fHeight: (2 * rowHeight) + spacing
    readonly property int availWidth: root.width > 0 ? root.width : 475
    readonly property int cubeWidth: Math.floor((availWidth - 3 * spacing) / 4)
    readonly property int wideWidth: 2 * cubeWidth + spacing
    readonly property int lastCubeWidth: availWidth - wideWidth - cubeWidth - (2 * spacing)
    readonly property int lastWideWidth: availWidth - wideWidth - spacing

    Layout.fillWidth: true
    Layout.leftMargin: 20
    Layout.rightMargin: 20
    Layout.preferredHeight: root.fHeight
    implicitHeight: root.fHeight
    height: root.fHeight

    ColumnLayout {
        id: contentColumn

        visible: !IPCLoader.dashboardWifiView && !IPCLoader.dashboardBluetoothView
        anchors.fill: parent
        spacing: root.spacing

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: root.rowHeight
            spacing: root.spacing

            SliceToggle {
                rWidth: root.wideWidth
                rHeight: root.rowHeight
                isToggled: Network.getBool()
                bigText: Network.textLabel
                smallText: {
                    if (Network.textLabel === "Disconnected")
                        return "Not connected";
                    else if (Network.textLabel === "Network Off")
                        return "Network disabled";
                    else if (Network.connectionType === "ethernet")
                        return "Wired connection";
                    else if (Network.connectionType === "vpn")
                        return "VPN active";
                    else
                        return "Connected";
                }
                icon: Network.getIcon()
                showChevron: true
                toRun: () => {
                    Network.toggle();
                }
                toRunChevron: () => {
                    IPCLoader.dashboardWifiView = true;
                    WifiService.scan(true);
                }
            }

            SliceToggle {
                rWidth: root.cubeWidth
                rHeight: root.rowHeight
                compact: true
                isToggled: Idle.keepAwake
                bigText: Idle.keepAwake ? "Keep\nAwake" : "Caffeine"
                icon: "coffee"
                iconSize: 25
                toRun: () => {
                    return Idle.toggleKeepAwake();
                }
            }

            SliceToggle {
                rWidth: root.lastCubeWidth
                rHeight: root.rowHeight
                compact: true
                isToggled: Notifications.popupInhibited
                bigText: Notifications.popupInhibited ? "Do Not\nDisturb" : "Disturb"
                icon: Notifications.popupInhibited ? "do_not_disturb_on" : "do_not_disturb_off"
                iconSize: 25
                toRun: () => {
                    return Notifications.toggleDND();
                }
            }

        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: root.rowHeight
            spacing: root.spacing

            SliceToggle {
                rWidth: root.wideWidth
                rHeight: root.rowHeight
                isToggled: Bluetooth.getBool()
                bigText: Bluetooth.textLabel
                smallText: {
                    if (Bluetooth.textLabel == "Not Connected")
                        return "No devices connected";
                    else if (Bluetooth.textLabel == "Bluetooth Off")
                        return "Wireless disabled";
                    else
                        return "Connected";
                }
                icon: Bluetooth.getIcon()
                showChevron: true
                toRun: () => {
                    return Bluetooth.toggle();
                }
                toRunChevron: () => {
                    IPCLoader.dashboardBluetoothView = true;
                    BluetoothService.scan(true);
                }
            }

            SliceToggle {
                rWidth: root.lastWideWidth
                rHeight: root.rowHeight
                isToggled: Nightmode.isNightmodeOn
                bigText: Nightmode.isNightmodeOn ? "Nightmode On" : "Nightmode Off"
                smallText: Nightmode.isNightmodeOn ? "Warm temperature" : "Cool temperature"
                icon: Nightmode.isNightmodeOn ? "bedtime" : "bedtime_off"
                toRun: () => {
                    return Nightmode.toggle();
                }
            }

        }

    }

    WifiSection {
        id: wifiSection

        visible: IPCLoader.dashboardWifiView
        anchors.fill: parent
    }

    BluetoothSection {
        id: bluetoothSection

        visible: IPCLoader.dashboardBluetoothView
        anchors.fill: parent
    }

}
