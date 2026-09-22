import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.core
import qs.features.common
import qs.services

StyledRect {
    id: root

    required property var modelData
    readonly property var deviceData: modelData
    property bool expanded: false

    readonly property string address: (deviceData && deviceData.address) ? deviceData.address : ""
    readonly property string name: (deviceData && deviceData.name) ? deviceData.name : "Unknown Device"
    readonly property string iconName: (deviceData && deviceData.icon) ? deviceData.icon : "bluetooth"
    readonly property bool isConnected: deviceData ? !!deviceData.isConnected : false
    readonly property bool isPaired: deviceData ? !!deviceData.isPaired : false
    readonly property bool isPairingThis: BluetoothService.isPairing && BluetoothService.pairingAddress === root.address
    readonly property bool isConnectingThis: BluetoothService.isConnecting && BluetoothService.connectingAddress === root.address
    readonly property bool batteryAvailable: deviceData ? !!deviceData.batteryAvailable : false
    readonly property int battery: (deviceData && deviceData.battery !== undefined) ? deviceData.battery : -1

    readonly property color fgColor: Colours.palette.on_surface
    readonly property color fgSubColor: Colours.palette.on_surface_variant

    function getCardRadius() {
        return Math.max(4, Config.get("borderRadius", 16) - 6);
    }

    variant: (itemMouseArea.containsMouse || root.expanded) ? "popup" : "pane"
    useDefaultRadius: false
    customRadius: root.getCardRadius()
    radius: root.getCardRadius()
    border.width: root.isConnected ? 1 : (root.expanded ? 1 : 0)
    border.color: root.isConnected ? Colours.palette.primary : (root.expanded ? Qt.alpha(Colours.palette.outline, 0.35) : "transparent")
    color: {
        if (root.isConnected)
            return Qt.alpha(Colours.palette.primary, 0.12);

        return Transparency.colorFor(variant);
    }
    implicitHeight: root.expanded ? (mainCol.implicitHeight + 16) : 48
    Layout.fillWidth: true

    // Card background click to toggle expansion / connect
    MouseArea {
        id: itemMouseArea

        anchors.fill: parent
        hoverEnabled: true
        enabled: !root.expanded
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (!root.expanded) {
                if (root.isConnected) {
                    root.expanded = true;
                } else if (root.isPaired) {
                    BluetoothService.connectDevice(root.address);
                } else {
                    BluetoothService.pairDevice(root.address);
                }
            }
        }
    }

    ColumnLayout {
        id: mainCol

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 8
        spacing: 8

        // Compact Top Row
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            spacing: 8

            // Bluetooth Device Icon
            Item {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                Layout.alignment: Qt.AlignVCenter

                Text {
                    anchors.centerIn: parent
                    text: root.iconName
                    font.family: Config.get("iconFont", "Material Symbols Rounded")
                    font.pixelSize: 20
                    color: root.isConnected ? Colours.palette.primary : Colours.palette.on_surface
                }
            }

            // Name & Status Column
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: root.name
                        font.family: Config.get("font", "SF Pro Display")
                        font.pixelSize: Styling.fontSize.body
                        font.weight: root.isConnected ? Font.Bold : Font.Medium
                        color: root.isConnected ? Colours.palette.primary : Colours.palette.on_surface
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    // Battery Pill (if available)
                    StyledRect {
                        visible: root.batteryAvailable && root.battery >= 0
                        variant: "internalbg"
                        useDefaultRadius: false
                        customRadius: 3
                        radius: 3
                        border.width: 0
                        color: root.isConnected ? Qt.alpha(Colours.palette.primary, 0.25) : Colours.palette.primary_container
                        implicitWidth: battRow.implicitWidth + 8
                        implicitHeight: 16

                        RowLayout {
                            id: battRow

                            anchors.centerIn: parent
                            spacing: 2

                            Text {
                                text: {
                                    if (root.battery >= 90) return "battery_full";
                                    if (root.battery >= 60) return "battery_5_bar";
                                    if (root.battery >= 40) return "battery_3_bar";
                                    if (root.battery >= 15) return "battery_1_bar";
                                    return "battery_alert";
                                }
                                font.family: Config.get("iconFont", "Material Symbols Rounded")
                                font.pixelSize: 10
                                color: root.isConnected ? Colours.palette.primary : Colours.palette.on_primary_container
                            }

                            Text {
                                text: root.battery + "%"
                                font.family: Config.get("font", "SF Pro Display")
                                font.pixelSize: 9
                                font.weight: Font.Bold
                                color: root.isConnected ? Colours.palette.primary : Colours.palette.on_primary_container
                            }
                        }
                    }

                    // Status Badge (Connected / Paired)
                    StyledRect {
                        visible: root.isConnected || root.isPaired
                        variant: "internalbg"
                        useDefaultRadius: false
                        customRadius: 3
                        radius: 3
                        border.width: 0
                        color: root.isConnected ? Colours.palette.primary : Colours.palette.surface_container_highest
                        implicitWidth: statusText.implicitWidth + 8
                        implicitHeight: 16

                        Text {
                            id: statusText

                            anchors.centerIn: parent
                            text: root.isConnected ? "Connected" : "Paired"
                            font.family: Config.get("font", "SF Pro Display")
                            font.pixelSize: 9
                            font.weight: Font.DemiBold
                            color: root.isConnected ? Colours.palette.on_primary : Colours.palette.on_surface_variant
                        }
                    }
                }

                Text {
                    text: {
                        if (root.isConnectingThis)
                            return "Connecting...";
                        if (root.isPairingThis)
                            return "Pairing...";
                        if (root.isConnected)
                            return root.battery >= 0 ? `Connected • ${root.battery}% battery` : "Connected";
                        if (root.isPaired)
                            return "Paired";
                        return "Available to pair • " + root.address;
                    }
                    font.family: Config.get("font", "SF Pro Display")
                    font.pixelSize: Styling.fontSize.caption
                    color: root.fgSubColor
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }

            // Quick Connect / Disconnect / Pair button (when collapsed)
            MButton {
                visible: !root.expanded && root.isConnected
                btnVariant: "secondary"
                text: "Disconnect"
                icon: "bluetooth_disabled"
                Layout.preferredHeight: 28
                Layout.fillWidth: false
                Layout.preferredWidth: implicitWidth
                textSize: Styling.fontSize.sm
                iconSize: 14
                onClicked: {
                    BluetoothService.disconnectDevice(root.address);
                }
            }

            MButton {
                visible: !root.expanded && !root.isConnected && root.isPaired
                btnVariant: "primary"
                text: root.isConnectingThis ? "Connecting..." : "Connect"
                icon: root.isConnectingThis ? "sync" : "bluetooth_connected"
                Layout.preferredHeight: 28
                Layout.fillWidth: false
                Layout.preferredWidth: implicitWidth
                textSize: Styling.fontSize.sm
                iconSize: 14
                enabled: !BluetoothService.isConnecting && !BluetoothService.isPairing
                onClicked: {
                    BluetoothService.connectDevice(root.address);
                }
            }

            MButton {
                visible: !root.expanded && !root.isConnected && !root.isPaired
                btnVariant: "secondary"
                text: root.isPairingThis ? "Pairing..." : "Pair"
                icon: root.isPairingThis ? "sync" : "link"
                Layout.preferredHeight: 28
                Layout.fillWidth: false
                Layout.preferredWidth: implicitWidth
                textSize: Styling.fontSize.sm
                iconSize: 14
                enabled: !BluetoothService.isConnecting && !BluetoothService.isPairing
                onClicked: {
                    BluetoothService.pairDevice(root.address);
                }
            }

            // Chevron toggle using MButton
            MButton {
                btnVariant: "iconOnly"
                icon: root.expanded ? "expand_less" : "expand_more"
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                iconSize: 18
                onClicked: root.expanded = !root.expanded
            }
        }

        // Expanded Section: Device management details
        ColumnLayout {
            Layout.fillWidth: true
            visible: root.expanded
            spacing: 10

            // Subtle divider line
            StyledRect {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                variant: "common"
                color: Qt.alpha(Colours.palette.outline, 0.25)
            }

            // Info rows
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "fingerprint"
                    font.family: Config.get("iconFont", "Material Symbols Rounded")
                    font.pixelSize: 16
                    color: Qt.alpha(Colours.palette.on_surface, 0.7)
                }

                Text {
                    text: "MAC: " + root.address
                    font.family: Config.get("font", "SF Pro Display")
                    font.pixelSize: Styling.fontSize.caption
                    color: root.fgSubColor
                    Layout.fillWidth: true
                }
            }

            // Action buttons row
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                spacing: 8

                // Forget / Unpair button (left-aligned)
                MButton {
                    visible: root.isPaired || root.isConnected
                    btnVariant: "secondary"
                    text: "Forget"
                    icon: "delete"
                    Layout.preferredHeight: 30
                    Layout.fillWidth: false
                    Layout.preferredWidth: implicitWidth
                    textSize: Styling.fontSize.sm
                    iconSize: 14
                    onClicked: {
                        BluetoothService.forgetDevice(root.address);
                        root.expanded = false;
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                // Cancel button
                MButton {
                    btnVariant: "secondary"
                    text: "Cancel"
                    Layout.preferredHeight: 30
                    Layout.fillWidth: false
                    Layout.preferredWidth: implicitWidth
                    textSize: Styling.fontSize.sm
                    onClicked: {
                        root.expanded = false;
                    }
                }

                // Disconnect button
                MButton {
                    visible: root.isConnected
                    btnVariant: "secondary"
                    text: "Disconnect"
                    icon: "bluetooth_disabled"
                    Layout.preferredHeight: 30
                    Layout.fillWidth: false
                    Layout.preferredWidth: implicitWidth
                    textSize: Styling.fontSize.sm
                    iconSize: 14
                    onClicked: {
                        BluetoothService.disconnectDevice(root.address);
                        root.expanded = false;
                    }
                }

                // Connect button
                MButton {
                    visible: !root.isConnected && root.isPaired
                    btnVariant: "primary"
                    text: root.isConnectingThis ? "Connecting..." : "Connect"
                    icon: root.isConnectingThis ? "sync" : "bluetooth_connected"
                    Layout.preferredHeight: 30
                    Layout.fillWidth: false
                    Layout.preferredWidth: implicitWidth
                    textSize: Styling.fontSize.sm
                    iconSize: 14
                    enabled: !root.isConnectingThis
                    onClicked: {
                        BluetoothService.connectDevice(root.address);
                    }
                }

                // Pair button
                MButton {
                    visible: !root.isConnected && !root.isPaired
                    btnVariant: "primary"
                    text: root.isPairingThis ? "Pairing..." : "Pair"
                    icon: root.isPairingThis ? "sync" : "link"
                    Layout.preferredHeight: 30
                    Layout.fillWidth: false
                    Layout.preferredWidth: implicitWidth
                    textSize: Styling.fontSize.sm
                    iconSize: 14
                    enabled: !root.isPairingThis
                    onClicked: {
                        BluetoothService.pairDevice(root.address);
                    }
                }
            }
        }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: Config.get("animationSpeed", 200)
            easing.type: Easing.OutCubic
        }
    }

    Behavior on color {
        PropertyAnimation {
            duration: Config.get("animationSpeed", 200)
            easing.type: Easing.InSine
        }
    }
}
