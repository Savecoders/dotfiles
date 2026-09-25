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

        // Header Row: Back button, Title & Status, Rescan, Wi-Fi Switch
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
                onClicked: IPCLoader.dashboardWifiView = false
            }

            // Wi-Fi Status Icon
            Text {
                text: WifiService.getWifiIcon(WifiService.activeSignal, WifiService.activeSsid !== "", false)
                font.family: Config.get("iconFont", "Material Symbols Rounded")
                font.pixelSize: 22
                color: WifiService.wifiEnabled ? Colours.palette.primary : Colours.palette.on_surface_variant
                Layout.alignment: Qt.AlignVCenter
            }

            // Title and Subtitle
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    text: "Wi-Fi Networks"
                    font.family: Config.get("font", "SF Pro Display")
                    font.pixelSize: Styling.fontSize.bodyLarge
                    font.weight: Font.Bold
                    color: Colours.palette.on_surface
                }

                Text {
                    text: {
                        if (!WifiService.wifiEnabled)
                            return "Wi-Fi is turned off";

                        if (WifiService.isScanning)
                            return "Scanning...";

                        if (WifiService.activeSsid !== "")
                            return "Connected to " + WifiService.activeSsid;

                        return "Select a network";
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
                enabled: WifiService.wifiEnabled && !WifiService.isScanning
                onClicked: WifiService.scan(true)

                RotationAnimator on rotation {
                    from: 0
                    to: 360
                    duration: 1000
                    loops: Animation.Infinite
                    running: WifiService.isScanning
                }

            }

            // Wi-Fi Power Switch Track
            StyledRect {
                id: switchTrack

                width: 44
                height: 22
                radius: 11
                useDefaultRadius: false
                border.width: 1
                border.color: WifiService.wifiEnabled ? Colours.palette.primary : Colours.palette.outline_variant
                color: WifiService.wifiEnabled ? Colours.palette.primary : Colours.palette.surface_container
                Layout.alignment: Qt.AlignVCenter

                StyledRect {
                    id: switchThumb

                    width: 16
                    height: 16
                    radius: 8
                    useDefaultRadius: false
                    border.width: 0
                    color: WifiService.wifiEnabled ? Colours.palette.on_primary : Colours.palette.on_surface_variant
                    anchors.verticalCenter: parent.verticalCenter
                    x: WifiService.wifiEnabled ? (switchTrack.width - width - 3) : 3

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
                    onClicked: WifiService.toggleWifi()
                }

            }

        }

        // Error message banner
        StyledRect {
            visible: WifiService.errorMessage !== ""
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
                    text: WifiService.errorMessage
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
                        onClicked: WifiService.errorMessage = ""
                    }

                }

            }

        }

        // Disabled State
        ColumnLayout {
            visible: !WifiService.wifiEnabled
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 6

            Text {
                text: "wifi_off"
                font.family: Config.get("iconFont", "Material Symbols Rounded")
                font.pixelSize: 36
                color: Colours.palette.on_surface_variant
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "Wi-Fi is Disabled"
                font.family: Config.get("font", "SF Pro Display")
                font.pixelSize: Styling.fontSize.body
                font.weight: Font.DemiBold
                color: Colours.palette.on_surface
                Layout.alignment: Qt.AlignHCenter
            }

            MButton {
                btnVariant: "primary"
                text: "Turn On"
                icon: "wifi"
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: 32
                Layout.fillWidth: false
                Layout.preferredWidth: implicitWidth
                textSize: Styling.fontSize.xs
                iconSize: 14
                onClicked: WifiService.toggleWifi()
            }

        }

        // Scanning State (Initial)
        ColumnLayout {
            visible: WifiService.wifiEnabled && WifiService.isScanning && WifiService.networks.length === 0
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
                    running: WifiService.isScanning && WifiService.networks.length === 0
                }

            }

            Text {
                text: "Scanning for networks..."
                font.family: Config.get("font", "SF Pro Display")
                font.pixelSize: Styling.fontSize.caption
                color: Colours.palette.on_surface_variant
                Layout.alignment: Qt.AlignHCenter
            }

        }

        // No Networks State
        ColumnLayout {
            visible: WifiService.wifiEnabled && !WifiService.isScanning && WifiService.networks.length === 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            Text {
                text: "signal_wifi_bad"
                font.family: Config.get("iconFont", "Material Symbols Rounded")
                font.pixelSize: 32
                color: Colours.palette.on_surface_variant
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "No Wi-Fi Networks Found"
                font.family: Config.get("font", "SF Pro Display")
                font.pixelSize: Styling.fontSize.caption
                color: Colours.palette.on_surface_variant
                Layout.alignment: Qt.AlignHCenter
            }

            MButton {
                btnVariant: "secondary"
                text: "Retry"
                icon: "refresh"
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: 30
                Layout.fillWidth: false
                Layout.preferredWidth: implicitWidth
                textSize: Styling.fontSize.xs
                iconSize: 14
                onClicked: WifiService.scan(true)
            }

        }

        // Scrollable List of Available Networks
        ListView {
            id: wifiListView

            visible: WifiService.wifiEnabled && WifiService.networks.length > 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 4
            model: WifiService.networks

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                width: 3
            }

            delegate: WifiNetworkItem {
                width: wifiListView.width
            }

        }

    }

}
