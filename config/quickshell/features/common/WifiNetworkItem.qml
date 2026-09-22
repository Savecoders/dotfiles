import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.core
import qs.features.common
import qs.services

StyledRect {
    id: root

    required property var modelData
    readonly property var networkData: modelData
    property bool expanded: false
    property bool showPassword: false
    readonly property string ssid: (networkData && networkData.ssid) ? networkData.ssid : ""
    readonly property bool isConnectingThis: WifiService.isConnecting && WifiService.connectingSsid === root.ssid
    readonly property bool isConnected: networkData ? !!networkData.isConnected : false
    readonly property bool isSaved: networkData ? !!networkData.isSaved : false
    readonly property bool isSecure: networkData ? !!networkData.isSecure : false
    readonly property int signalStrength: (networkData && networkData.signal !== undefined) ? networkData.signal : 0
    readonly property bool is5GHz: networkData ? !!networkData.is5GHz : false
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

    onExpandedChanged: {
        if (root.expanded && !root.isConnected) {
            Qt.callLater(() => {
                if (passwordInput)
                    passwordInput.forceActiveFocus();
            });
        }
    }

    // Card background click to toggle expansion / connect
    MouseArea {
        id: itemMouseArea

        anchors.fill: parent
        hoverEnabled: true
        enabled: !root.expanded
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (!root.expanded) {
                if (root.isConnected || (!root.isSaved && root.isSecure))
                    root.expanded = true;
                else
                    WifiService.connectToNetwork(root.ssid, "");
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

            // Wi-Fi Signal Icon with Lock Badge
            Item {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                Layout.alignment: Qt.AlignVCenter

                Text {
                    anchors.centerIn: parent
                    text: root.networkData ? (root.networkData.icon || "network_wifi") : "network_wifi"
                    font.family: Config.get("iconFont", "Material Symbols Rounded")
                    font.pixelSize: 20
                    color: root.isConnected ? Colours.palette.primary : Colours.palette.on_surface
                }

                Text {
                    visible: root.isSecure
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: -2
                    text: "lock"
                    font.family: Config.get("iconFont", "Material Symbols Rounded")
                    font.pixelSize: 10
                    color: root.isConnected ? Colours.palette.primary : Colours.palette.on_surface_variant
                }

            }

            // SSID Name & Details
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: root.ssid !== "" ? root.ssid : "Unknown"
                        font.family: Config.get("font", "SF Pro Display")
                        font.pixelSize: Styling.fontSize.body
                        font.weight: root.isConnected ? Font.Bold : Font.Medium
                        color: root.isConnected ? Colours.palette.primary : Colours.palette.on_surface
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    // 5G Pill
                    StyledRect {
                        visible: root.is5GHz
                        variant: "internalbg"
                        useDefaultRadius: false
                        customRadius: 3
                        radius: 3
                        border.width: 0
                        color: root.isConnected ? Qt.alpha(Colours.palette.primary, 0.25) : Colours.palette.primary_container
                        implicitWidth: fiveGText.implicitWidth + 6
                        implicitHeight: 16

                        Text {
                            id: fiveGText

                            anchors.centerIn: parent
                            text: "5G"
                            font.family: Config.get("font", "SF Pro Display")
                            font.pixelSize: 9
                            font.weight: Font.Bold
                            color: root.isConnected ? Colours.palette.primary : Colours.palette.on_primary_container
                        }

                    }

                    // Status Badge (Connected / Saved)
                    StyledRect {
                        visible: root.isConnected || root.isSaved
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
                            text: root.isConnected ? "Connected" : "Saved"
                            font.family: Config.get("font", "SF Pro Display")
                            font.pixelSize: 9
                            font.weight: Font.DemiBold
                            color: root.isConnected ? Colours.palette.on_primary : Colours.palette.on_surface_variant
                        }

                    }

                }

                Text {
                    text: {
                        let sec = (root.networkData && root.networkData.security) ? root.networkData.security : (root.isSecure ? "Secured" : "Open");
                        return `${sec} • ${root.signalStrength}% signal`;
                    }
                    font.family: Config.get("font", "SF Pro Display")
                    font.pixelSize: Styling.fontSize.caption
                    color: root.fgSubColor
                }

            }

            // Quick Connect / Key Action Button (when collapsed)
            MButton {
                visible: !root.expanded && !root.isConnected && (root.isSaved || !root.isSecure)
                btnVariant: root.isSaved ? "primary" : "secondary"
                text: "Connect"
                icon: "check"
                Layout.preferredHeight: 28
                Layout.fillWidth: false
                Layout.preferredWidth: implicitWidth
                textSize: Styling.fontSize.sm
                iconSize: 14
                enabled: !WifiService.isConnecting
                onClicked: {
                    WifiService.connectToNetwork(root.ssid, "");
                }
            }

            MButton {
                visible: !root.expanded && !root.isConnected && !root.isSaved && root.isSecure
                btnVariant: "secondary"
                text: "Join"
                icon: "key"
                Layout.preferredHeight: 28
                Layout.fillWidth: false
                Layout.preferredWidth: implicitWidth
                textSize: Styling.fontSize.sm
                iconSize: 14
                enabled: !WifiService.isConnecting
                onClicked: {
                    root.expanded = true;
                }
            }

            // Quick Disconnect Button (when collapsed)
            MButton {
                visible: !root.expanded && root.isConnected
                btnVariant: "secondary"
                text: "Disconnect"
                icon: "wifi_off"
                Layout.preferredHeight: 28
                Layout.fillWidth: false
                Layout.preferredWidth: implicitWidth
                textSize: Styling.fontSize.sm
                iconSize: 14
                onClicked: WifiService.disconnectNetwork(root.ssid)
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

        // Expanded Section: Password Form matching Settings forms
        ColumnLayout {
            Layout.fillWidth: true
            visible: root.expanded
            spacing: 10

            // Subtle divider line matching Settings
            StyledRect {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                variant: "common"
                color: Qt.alpha(Colours.palette.outline, 0.25)
            }

            // Connecting indicator row
            RowLayout {
                visible: root.isConnectingThis
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                spacing: 8

                Text {
                    text: "sync"
                    font.family: Config.get("iconFont", "Material Symbols Rounded")
                    font.pixelSize: 16
                    color: Colours.palette.primary

                    RotationAnimator on rotation {
                        from: 0
                        to: 360
                        duration: 1000
                        loops: Animation.Infinite
                        running: root.isConnectingThis
                    }

                }

                Text {
                    text: "Connecting to " + root.ssid + "..."
                    font.family: Config.get("font", "SF Pro Display")
                    font.pixelSize: Styling.fontSize.body
                    color: Colours.palette.primary
                    Layout.fillWidth: true
                }

            }

            // Password Field Row matching GenericTextOption.qml and MiscPage.qml
            RowLayout {
                visible: !root.isConnected && !root.isConnectingThis
                Layout.fillWidth: true
                Layout.preferredHeight: 34
                spacing: 8

                // Left: Field label with key icon matching Settings
                RowLayout {
                    spacing: 6
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                    Text {
                        text: "key"
                        font.family: Config.get("iconFont", "Material Symbols Rounded")
                        font.pixelSize: 18
                        color: Qt.alpha(Colours.palette.on_surface, 0.75)
                    }

                    Text {
                        text: "Password"
                        font.family: Config.get("font", "SF Pro Display")
                        font.pixelSize: Styling.fontSize.body
                        font.weight: Font.Medium
                        color: Qt.alpha(Colours.palette.on_surface, 0.9)
                    }

                }

                Item {
                    Layout.fillWidth: true
                }

                // Right: Input field and Eye button matching MiscPage.qml (dirInput + browseBtn)
                RowLayout {
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    spacing: 6

                    TextField {
                        id: passwordInput

                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 32
                        echoMode: root.showPassword ? TextInput.Normal : TextInput.Password
                        text: ""
                        placeholderText: root.isSaved ? "Saved password" : "Enter password..."
                        placeholderTextColor: Qt.alpha(Colours.palette.on_surface_variant, 0.5)
                        color: Colours.palette.on_surface
                        font.family: Config.get("font", "SF Pro Display")
                        font.pixelSize: Styling.fontSize.body
                        selectByMouse: true
                        focus: root.expanded && !root.isConnected
                        activeFocusOnTab: true
                        cursorVisible: activeFocus

                        onPressed: {
                            passwordInput.forceActiveFocus();
                        }

                        Keys.onReturnPressed: {
                            if (root.ssid !== "")
                                WifiService.connectToNetwork(root.ssid, passwordInput.text);

                        }

                        Keys.onEscapePressed: {
                            root.expanded = false;
                        }

                        background: StyledRect {
                            variant: "internalbg"
                            useDefaultRadius: false
                            customRadius: Math.max(4, Config.get("borderRadius", 16) - 10)
                            radius: Math.max(4, Config.get("borderRadius", 16) - 10)
                            border.color: passwordInput.activeFocus ? Colours.palette.primary : Qt.alpha(Colours.palette.outline, 0.5)
                            border.width: 1
                        }

                    }

                    // Eye toggle button reusing MButton
                    MButton {
                        id: eyeBtn

                        btnVariant: "iconOnly"
                        icon: root.showPassword ? "visibility_off" : "visibility"
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        iconSize: 18
                        accessibleLabel: root.showPassword ? "Hide password" : "Show password"
                        onClicked: root.showPassword = !root.showPassword
                    }

                }

            }

            // Connected status info row (when connected)
            RowLayout {
                visible: root.isConnected
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                spacing: 8

                Text {
                    text: "check_circle"
                    font.family: Config.get("iconFont", "Material Symbols Rounded")
                    font.pixelSize: 18
                    color: Colours.palette.primary
                }

                Text {
                    text: "Connected and active"
                    font.family: Config.get("font", "SF Pro Display")
                    font.pixelSize: Styling.fontSize.body
                    color: Colours.palette.on_surface
                    Layout.fillWidth: true
                }

            }

            // Expanded action buttons row matching Settings button layout
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                spacing: 8

                // Forget button (left-aligned)
                MButton {
                    visible: root.isSaved || root.isConnected
                    btnVariant: "secondary"
                    text: "Forget"
                    icon: "delete"
                    Layout.preferredHeight: 30
                    Layout.fillWidth: false
                    Layout.preferredWidth: implicitWidth
                    textSize: Styling.fontSize.sm
                    iconSize: 14
                    onClicked: {
                        WifiService.forgetNetwork(root.ssid);
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
                        passwordInput.text = "";
                    }
                }

                // Disconnect button
                MButton {
                    visible: root.isConnected
                    btnVariant: "secondary"
                    text: "Disconnect"
                    icon: "wifi_off"
                    Layout.preferredHeight: 30
                    Layout.fillWidth: false
                    Layout.preferredWidth: implicitWidth
                    textSize: Styling.fontSize.sm
                    iconSize: 14
                    onClicked: {
                        WifiService.disconnectNetwork(root.ssid);
                        root.expanded = false;
                    }
                }

                // Connect button
                MButton {
                    visible: !root.isConnected
                    btnVariant: "primary"
                    text: root.isConnectingThis ? "Connecting..." : "Connect"
                    icon: root.isConnectingThis ? "sync" : "wifi"
                    Layout.preferredHeight: 30
                    Layout.fillWidth: false
                    Layout.preferredWidth: implicitWidth
                    textSize: Styling.fontSize.sm
                    iconSize: 14
                    enabled: !root.isConnectingThis && (root.isSaved || !root.isSecure || passwordInput.text.length > 0)
                    onClicked: {
                        if (root.ssid !== "")
                            WifiService.connectToNetwork(root.ssid, passwordInput.text);

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
