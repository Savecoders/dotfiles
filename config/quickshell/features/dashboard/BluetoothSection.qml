import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.core
import qs.features
import qs.features.common
import qs.services

Item {
    id: root

    implicitHeight: 216
    Layout.preferredHeight: 216
    height: 216
    Layout.fillWidth: true
    clip: true

    ColumnLayout {
        anchors.fill: parent
        spacing: Styling.spacing.sm

        // Header Row: Back button, Title & Status, Rescan, Bluetooth Switch
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            spacing: Styling.spacing.sm

            // Back Button reusing MButton
            MButton {
                btnVariant: "iconOnly"
                icon: "arrow_back"
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                iconSize: 18
                onClicked: IPCLoader.dashboardBluetoothView = false
            }

            // Bluetooth Status Icon
            Text {
                text: BluetoothService.bluetoothEnabled ? (BluetoothService.connectedCount > 0 ? "bluetooth_connected" : "bluetooth") : "bluetooth_disabled"
                font.family: Config.get("iconFont", "Material Symbols Rounded")
                font.pixelSize: 22
                color: BluetoothService.bluetoothEnabled ? Colours.palette.primary : Colours.palette.on_surface_variant
                Layout.alignment: Qt.AlignVCenter
            }

            // Title and Subtitle
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    text: "Bluetooth Devices"
                    font.family: Config.get("font", "SF Pro Display")
                    font.pixelSize: Styling.fontSize.bodyLarge
                    font.weight: Font.Bold
                    color: Colours.palette.on_surface
                }

                Text {
                    text: {
                        if (!BluetoothService.bluetoothEnabled)
                            return "Bluetooth is turned off";

                        if (BluetoothService.isScanning)
                            return "Scanning for devices...";

                        if (BluetoothService.activeDeviceName !== "")
                            return "Connected: " + BluetoothService.activeDeviceName;

                        return "Select a device to pair";
                    }
                    font.family: Config.get("font", "SF Pro Display")
                    font.pixelSize: Styling.fontSize.xs
                    color: Colours.palette.on_surface_variant
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

            }

            // Rescan Button reusing MButton
            MButton {
                btnVariant: "iconOnly"
                icon: "refresh"
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                iconSize: 18
                enabled: BluetoothService.bluetoothEnabled && !BluetoothService.isScanning
                onClicked: BluetoothService.scan(true)

                RotationAnimator on rotation {
                    from: 0
                    to: 360
                    duration: 1000
                    loops: Animation.Infinite
                    running: BluetoothService.isScanning
                }

            }

            // Bluetooth Power Switch Track
            StyledRect {
                id: switchTrack

                width: 44
                height: 22
                radius: 11
                useDefaultRadius: false
                border.width: 1
                border.color: BluetoothService.bluetoothEnabled ? Colours.palette.primary : Colours.palette.outline_variant
                color: BluetoothService.bluetoothEnabled ? Colours.palette.primary : Colours.palette.surface_container
                Layout.alignment: Qt.AlignVCenter

                StyledRect {
                    id: switchThumb

                    width: 16
                    height: 16
                    radius: 8
                    useDefaultRadius: false
                    border.width: 0
                    color: BluetoothService.bluetoothEnabled ? Colours.palette.on_primary : Colours.palette.on_surface_variant
                    anchors.verticalCenter: parent.verticalCenter
                    x: BluetoothService.bluetoothEnabled ? (switchTrack.width - width - 3) : 3

                    Behavior on x {
                        NumberAnimation {
                            duration: Config.settings.animationSpeed ?? 150
                            easing.type: Easing.OutCubic
                        }

                    }

                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: BluetoothService.toggleBluetooth()
                }

            }

        }

        // Error message banner
        StyledRect {
            visible: BluetoothService.errorMessage !== ""
            Layout.fillWidth: true
            Layout.preferredHeight: 26
            variant: "common"
            useDefaultRadius: false
            radius: Math.max(4, Config.get("borderRadius", 8) - 4)
            border.width: 0
            color: Qt.alpha(Colours.palette.error, 0.15)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 6

                Text {
                    text: "error"
                    font.family: Config.get("iconFont", "Material Symbols Rounded")
                    font.pixelSize: 14
                    color: Colours.palette.error
                }

                Text {
                    Layout.fillWidth: true
                    text: BluetoothService.errorMessage
                    font.family: Config.get("font", "SF Pro Display")
                    font.pixelSize: Styling.fontSize.caption
                    color: Colours.palette.error
                    elide: Text.ElideRight
                }

                Text {
                    text: "close"
                    font.family: Config.get("iconFont", "Material Symbols Rounded")
                    font.pixelSize: 14
                    color: Colours.palette.error

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: BluetoothService.errorMessage = ""
                    }

                }

            }

        }

        // Disabled State
        ColumnLayout {
            visible: !BluetoothService.bluetoothEnabled
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 6

            Text {
                text: "bluetooth_disabled"
                font.family: Config.get("iconFont", "Material Symbols Rounded")
                font.pixelSize: 36
                color: Colours.palette.on_surface_variant
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "Bluetooth is Disabled"
                font.family: Config.get("font", "SF Pro Display")
                font.pixelSize: Styling.fontSize.body
                font.weight: Font.DemiBold
                color: Colours.palette.on_surface
                Layout.alignment: Qt.AlignHCenter
            }

            MButton {
                btnVariant: "primary"
                text: "Turn On"
                icon: "bluetooth"
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: 32
                Layout.fillWidth: false
                Layout.preferredWidth: implicitWidth
                textSize: Styling.fontSize.xs
                iconSize: 14
                onClicked: BluetoothService.toggleBluetooth()
            }

        }

        // Scanning State (Initial)
        ColumnLayout {
            visible: BluetoothService.bluetoothEnabled && BluetoothService.isScanning && BluetoothService.devices.length === 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            Text {
                text: "sync"
                font.family: Config.get("iconFont", "Material Symbols Rounded")
                font.pixelSize: 32
                color: Colours.palette.primary
                Layout.alignment: Qt.AlignHCenter

                RotationAnimator on rotation {
                    from: 0
                    to: 360
                    duration: 1000
                    loops: Animation.Infinite
                    running: BluetoothService.isScanning && BluetoothService.devices.length === 0
                }

            }

            Text {
                text: "Scanning for Bluetooth devices..."
                font.family: Config.get("font", "SF Pro Display")
                font.pixelSize: Styling.fontSize.caption
                color: Colours.palette.on_surface_variant
                Layout.alignment: Qt.AlignHCenter
            }

        }

        // No Devices State
        ColumnLayout {
            visible: BluetoothService.bluetoothEnabled && !BluetoothService.isScanning && BluetoothService.devices.length === 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            Text {
                text: "bluetooth_searching"
                font.family: Config.get("iconFont", "Material Symbols Rounded")
                font.pixelSize: 32
                color: Colours.palette.on_surface_variant
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "No Bluetooth Devices Found"
                font.family: Config.get("font", "SF Pro Display")
                font.pixelSize: Styling.fontSize.caption
                color: Colours.palette.on_surface_variant
                Layout.alignment: Qt.AlignHCenter
            }

            MButton {
                btnVariant: "secondary"
                text: "Scan"
                icon: "refresh"
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: 30
                Layout.fillWidth: false
                Layout.preferredWidth: implicitWidth
                textSize: Styling.fontSize.xs
                iconSize: 14
                onClicked: BluetoothService.scan(true)
            }

        }

        // Scrollable List of Available / Paired Devices
        ListView {
            id: btListView

            visible: BluetoothService.bluetoothEnabled && BluetoothService.devices.length > 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 4
            model: BluetoothService.devices

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                width: 3
            }

            delegate: BluetoothDeviceItem {
                width: btListView.width
            }

        }

    }

}
