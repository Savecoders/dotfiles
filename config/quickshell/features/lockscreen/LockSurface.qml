import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.core
import qs.features.common
import qs.features.lockscreen
import qs.services

Rectangle {
    id: root

    required property LockContext context
    // Reactive Lockscreen Settings & Border Radius bindings from Config.settings
    readonly property bool showClock: Config.settings && Config.settings.lockscreen ? (Config.settings.lockscreen.showClock !== false) : true
    readonly property bool showDate: Config.settings && Config.settings.lockscreen ? (Config.settings.lockscreen.showDate !== false) : true
    readonly property bool blurBackground: Config.settings && Config.settings.lockscreen ? (Config.settings.lockscreen.blurBackground !== false) : true
    readonly property bool showMedia: Config.settings && Config.settings.lockscreen ? (Config.settings.lockscreen.showMedia !== false) : true
    readonly property bool showSystemPill: Config.settings && Config.settings.lockscreen ? (Config.settings.lockscreen.showSystemPill !== false) : true
    readonly property bool showPowerBtn: Config.settings && Config.settings.lockscreen ? (Config.settings.lockscreen.showPowerBtn !== false) : true
    readonly property real configBorderRadius: (Config.settings && Config.settings.borderRadius !== undefined) ? Config.settings.borderRadius : 4
    readonly property real cardRadius: root.configBorderRadius
    readonly property real innerRadius: Math.max(2, root.configBorderRadius - 2)
    readonly property real btnRadius: Math.max(2, root.configBorderRadius - 2)
    property bool isUnlocked: false
    property bool revealPassword: false

    color: Colours.palette.background
    Component.onCompleted: {
        if (root.isUnlocked)
            passwordBox.forceActiveFocus();

    }

    // Define Background Wallpaper & Blur (Matching SDDM FastBlur quality & depth)
    Image {
        id: background

        source: Config.settings.currentWallpaper
        fillMode: Image.PreserveAspectCrop
        asynchronous: false
        cache: false
        anchors.fill: parent
        scale: 1.05
        visible: !root.blurBackground
    }

    MultiEffect {
        id: blurEffect

        visible: root.blurBackground
        source: background
        anchors.fill: parent
        blurEnabled: true
        blurMax: 32
        blur: 1
    }

    // Dark Overlay & Global Click/Key Listener
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: {
            if (!root.isUnlocked) {
                root.isUnlocked = true;
                passwordBox.forceActiveFocus();
            }
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.4)
        }

    }

    Item {
        focus: true
        Keys.onPressed: (event) => {
            if (!root.isUnlocked) {
                root.isUnlocked = true;
                passwordBox.forceActiveFocus();
            }
        }
    }

    // CENTERED CLOCK & DATE (Upper-Middle Center of Screen - Permanently Visible)
    ColumnLayout {
        id: centeredHeader

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -60
        spacing: 6
        visible: root.showClock || root.showDate

        Text {
            visible: root.showClock
            text: Time.time
            color: Qt.rgba(1, 1, 1, 0.95)
            font.family: Config.settings.font
            font.pixelSize: 104
            font.weight: Font.ExtraBold
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            visible: root.showDate
            text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
            color: Qt.rgba(1, 1, 1, 0.85)
            font.family: Config.settings.font
            font.pixelSize: 28
            font.weight: Font.DemiBold
            Layout.alignment: Qt.AlignHCenter
        }

    }

    // Pulsing "Click or press Enter to unlock" Prompt
    Item {
        id: unlockPrompt

        width: 360
        height: 44
        opacity: root.isUnlocked ? 0 : 1
        visible: opacity > 0

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: centeredHeader.bottom
            topMargin: 36
        }

        Text {
            anchors.centerIn: parent
            text: "Click or press Enter to unlock"
            color: Qt.rgba(1, 1, 1, 0.85)
            font.family: Config.settings.font
            font.pixelSize: 16
            font.weight: Font.Medium

            SequentialAnimation on opacity {
                running: !root.isUnlocked
                loops: Animation.Infinite

                NumberAnimation {
                    to: 0.3
                    duration: 1000
                }

                NumberAnimation {
                    to: 1
                    duration: 1000
                }

            }

        }

        Behavior on opacity {
            NumberAnimation {
                duration: 250
            }

        }

    }

    // 3. ACTIVE / UNLOCKED STATE: HORIZONTAL BOTTOM BAR (3 Cards Layout matching SDDM)
    RowLayout {
        id: bottomHorizontalBar

        spacing: 16
        opacity: root.isUnlocked ? 1 : 0
        scale: root.isUnlocked ? 1 : 0.95
        visible: opacity > 0

        anchors {
            bottom: parent.bottom
            bottomMargin: 36
            horizontalCenter: parent.horizontalCenter
        }

        // Music Player Card
        Item {
            visible: root.showMedia
            implicitWidth: 340
            implicitHeight: 64

            MusicCard {
                anchors.fill: parent
                cardHeight: 64
                cardRadius: root.cardRadius
            }

        }

        // Bottom Center Horizontal Login Card (Avatar + Password Input, NO Username Pill)
        Rectangle {
            id: loginCard

            implicitWidth: 380
            implicitHeight: 64
            radius: root.cardRadius
            color: Qt.rgba(0, 0, 0, 0.5)
            border.color: root.context.showFailure ? (Colours.palette.error ? Colours.palette.error : "#ffb4ab") : Qt.rgba(1, 1, 1, 0.15)
            border.width: 1

            // Floating Error Tooltip Pill above Login Card
            Rectangle {
                visible: root.context.showFailure
                opacity: root.context.showFailure ? 1 : 0
                implicitWidth: errorRow.implicitWidth + 24
                implicitHeight: 30
                radius: Math.max(4, root.innerRadius)
                color: Colours.palette.error
                anchors.bottom: parent.top
                anchors.bottomMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter

                RowLayout {
                    id: errorRow

                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: "error"
                        font.family: Config.settings.iconFont
                        font.pixelSize: 16
                        color: Colours.palette.on_error
                    }

                    Text {
                        text: "Incorrect password"
                        color: Colours.palette.on_error
                        font.family: Config.settings.font
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }

                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                    }

                }

            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 10

                // User Profile Avatar Circle (Matches SDDM Avatar style)
                Rectangle {
                    width: 44
                    height: 44
                    radius: root.innerRadius
                    color: Colours.palette.primary_container ? Colours.palette.primary_container : "#005141"
                    border.color: Colours.palette.primary ? Colours.palette.primary : "#87d6bd"
                    border.width: 2
                    Layout.alignment: Qt.AlignVCenter

                    Image {
                        id: avatarImg

                        anchors.fill: parent
                        anchors.margins: 2
                        fillMode: Image.PreserveAspectCrop
                        source: {
                            let usePfp = Config.settings && Config.settings.usePfpInsteadOfLogo !== undefined ? Config.settings.usePfpInsteadOfLogo : true;
                            if (usePfp) {
                                let loc = Config.settings.pfpLocation || "~/.face";
                                let path = loc.startsWith("/") ? loc : `${Quickshell.env("HOME")}/${loc.replace(/^~\//, "")}`;
                                return `file://${path}`;
                            } else {
                                return Qt.resolvedUrl(Quickshell.shellDir + "/assets/icon.png");
                            }
                        }
                        onStatusChanged: {
                            if (status === Image.Error || status === Image.Null)
                                source = Qt.resolvedUrl(Quickshell.shellDir + "/assets/icon.png");

                        }
                    }

                }

                // Password Input Container (Matches Savior SDDM Password Input style & color)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    radius: root.innerRadius
                    color: Qt.rgba(0, 0, 0, 0.4)
                    border.color: passwordBox.activeFocus ? (Colours.palette.primary ? Colours.palette.primary : "#87d6bd") : Qt.rgba(1, 1, 1, 0.12)
                    border.width: passwordBox.activeFocus ? 2 : 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 10
                        spacing: 8

                        Text {
                            text: "lock"
                            font.family: Config.settings.iconFont
                            font.pixelSize: 18
                            color: passwordBox.activeFocus ? (Colours.palette.primary ? Colours.palette.primary : "#87d6bd") : Qt.rgba(1, 1, 1, 0.6)
                        }

                        TextField {
                            id: passwordBox

                            focus: root.isUnlocked
                            Layout.fillWidth: true
                            echoMode: root.revealPassword ? TextInput.Normal : TextInput.Password
                            passwordCharacter: "•"
                            color: Colours.palette.on_surface ? Colours.palette.on_surface : "#dee4e0"
                            selectionColor: Colours.palette.primary
                            selectedTextColor: Colours.palette.on_primary
                            font.family: Config.settings.font
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            verticalAlignment: Text.AlignVCenter
                            onTextChanged: {
                                if (text.length > 0 && !root.isUnlocked)
                                    root.isUnlocked = true;

                                if (root.context.currentText !== text)
                                    root.context.currentText = text;

                            }
                            onAccepted: {
                                root.context.tryUnlock();
                            }

                            // Placeholder matching SDDM (hidden when focused or text entered)
                            Text {
                                anchors.fill: parent
                                text: "Password"
                                color: Qt.rgba(1, 1, 1, 0.5)
                                font: passwordBox.font
                                visible: !passwordBox.text && !passwordBox.activeFocus
                                verticalAlignment: Text.AlignVCenter
                            }

                            Connections {
                                function onCurrentTextChanged() {
                                    if (passwordBox.text !== root.context.currentText)
                                        passwordBox.text = root.context.currentText;

                                }

                                target: root.context
                            }

                            background: Item {
                            }

                        }

                        // Eye Reveal Toggle Button
                        Rectangle {
                            id: eyeBtn

                            property bool hovered: false

                            width: 30
                            height: 30
                            radius: Math.max(2, root.innerRadius - 2)
                            color: hovered ? Qt.rgba(1, 1, 1, 0.15) : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: root.revealPassword ? "visibility_off" : "visibility"
                                font.family: Config.settings.iconFont
                                font.pixelSize: 18
                                color: root.revealPassword ? Colours.palette.primary : Qt.rgba(1, 1, 1, 0.6)
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: eyeBtn.hovered = true
                                onExited: eyeBtn.hovered = false
                                onClicked: root.revealPassword = !root.revealPassword
                            }

                        }

                    }

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 150
                        }

                    }

                }

                // Unlock Action Button (Circular Arrow Button - Matches SDDM)
                Rectangle {
                    id: unlockBtn

                    property bool hovered: false
                    property bool pressed: false

                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    radius: root.btnRadius
                    color: pressed ? Qt.alpha(Colours.palette.primary, 0.7) : (hovered ? Qt.alpha(Colours.palette.primary, 0.9) : Colours.palette.primary)

                    Text {
                        anchors.centerIn: parent
                        text: "arrow_forward"
                        font.family: Config.settings.iconFont
                        font.pixelSize: 18
                        color: Colours.palette.on_primary
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: unlockBtn.hovered = true
                        onExited: unlockBtn.hovered = false
                        onPressed: unlockBtn.pressed = true
                        onReleased: unlockBtn.pressed = false
                        onClicked: root.context.tryUnlock()
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }

                    }

                }

            }

            transform: Translate {
                id: shakeTranslate

                x: 0
            }

        }

        // CARD 3 (RIGHT): Controls Pill & Power Bar (Matches SDDM PowerBar style & Config.settings.borderRadius)
        Rectangle {
            id: powerBar

            implicitWidth: 380
            implicitHeight: 64
            radius: root.cardRadius
            color: Qt.rgba(0, 0, 0, 0.5)
            border.color: Qt.rgba(1, 1, 1, 0.15)
            border.width: 1

            RowLayout {
                spacing: 8

                anchors {
                    fill: parent
                    leftMargin: 12
                    rightMargin: 12
                }

                // System Metrics & Status Pill
                Rectangle {
                    visible: root.showSystemPill
                    Layout.fillWidth: true
                    implicitHeight: 40
                    radius: root.innerRadius
                    color: Qt.rgba(0, 0, 0, 0.35)
                    border.color: Qt.rgba(1, 1, 1, 0.1)
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 10

                        Text {
                            text: Config.settings.notifications && Config.settings.notifications.doNotDisturb ? "notifications_off" : "notifications"
                            font.family: Config.settings.iconFont
                            font.pixelSize: 18
                            color: Qt.rgba(1, 1, 1, 0.8)
                        }

                        QuickStatusGroup {
                            showClock: false
                            showNetwork: true
                            showBluetooth: true
                            showBattery: true
                            showBatteryPercentage: true
                            contentColor: Qt.rgba(1, 1, 1, 0.9)
                            iconPixelSize: 18
                        }

                    }

                }

                // Suspend Button
                Rectangle {
                    id: suspBtn

                    property bool hovered: false

                    width: 38
                    height: 38
                    radius: root.btnRadius
                    color: hovered ? Qt.rgba(1, 1, 1, 0.2) : Qt.rgba(0, 0, 0, 0.35)
                    border.color: Qt.rgba(1, 1, 1, 0.1)
                    border.width: 1

                    Text {
                        text: "bedtime"
                        font.family: Config.settings.iconFont
                        font.pixelSize: 18
                        color: Qt.rgba(1, 1, 1, 0.9)
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: suspBtn.hovered = true
                        onExited: suspBtn.hovered = false
                        onClicked: Quickshell.execDetached(["systemctl", "suspend"])
                    }

                }

                // Reboot Button
                Rectangle {
                    id: rebBtn

                    property bool hovered: false

                    width: 38
                    height: 38
                    radius: root.btnRadius
                    color: hovered ? Qt.rgba(1, 1, 1, 0.2) : Qt.rgba(0, 0, 0, 0.35)
                    border.color: Qt.rgba(1, 1, 1, 0.1)
                    border.width: 1

                    Text {
                        text: "restart_alt"
                        font.family: Config.settings.iconFont
                        font.pixelSize: 18
                        color: Qt.rgba(1, 1, 1, 0.9)
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: rebBtn.hovered = true
                        onExited: rebBtn.hovered = false
                        onClicked: Quickshell.execDetached(["systemctl", "reboot"])
                    }

                }

                // Power Button
                Rectangle {
                    id: powerBtn

                    property bool hovered: false

                    visible: root.showPowerBtn
                    width: 38
                    height: 38
                    radius: root.btnRadius
                    color: hovered ? Colours.palette.error : Qt.rgba(0, 0, 0, 0.35)
                    border.color: hovered ? Colours.palette.error : Qt.rgba(1, 1, 1, 0.1)
                    border.width: 1

                    Text {
                        text: "power_settings_new"
                        font.family: Config.settings.iconFont
                        font.pixelSize: 18
                        color: powerBtn.hovered ? Colours.palette.on_error : Qt.rgba(1, 1, 1, 0.9)
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: powerBtn.hovered = true
                        onExited: powerBtn.hovered = false
                        onClicked: Quickshell.execDetached(["wlogout"])
                    }

                }

            }

        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutBack
            }

        }

    }

    // Shake animation on incorrect password
    Connections {
        function onShowFailureChanged() {
            if (root.context.showFailure) {
                if (!root.isUnlocked)
                    root.isUnlocked = true;

                shakeAnim.restart();
            }
        }

        target: root.context
    }

    SequentialAnimation {
        id: shakeAnim

        NumberAnimation {
            target: shakeTranslate
            property: "x"
            to: -12
            duration: 50
        }

        NumberAnimation {
            target: shakeTranslate
            property: "x"
            to: 12
            duration: 50
        }

        NumberAnimation {
            target: shakeTranslate
            property: "x"
            to: -8
            duration: 50
        }

        NumberAnimation {
            target: shakeTranslate
            property: "x"
            to: 8
            duration: 50
        }

        NumberAnimation {
            target: shakeTranslate
            property: "x"
            to: 0
            duration: 50
        }

    }

}
