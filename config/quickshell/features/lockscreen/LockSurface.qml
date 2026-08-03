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
    readonly property var cfg: Config.settings.lockscreen || {
        "blurBackground": true,
        "showClock": true,
        "showDate": true,
        "showMedia": true,
        "showSystemPill": true,
        "showPowerBtn": true
    }
    property bool isUnlocked: false
    property bool revealPassword: false

    color: Colours.palette.background
    Component.onCompleted: {
        if (root.isUnlocked)
            passwordBox.forceActiveFocus();

    }

    Image {
        id: background

        source: Config.settings.currentWallpaper
        fillMode: Image.PreserveAspectCrop
        asynchronous: false
        cache: false
        anchors.fill: parent
        scale: 1.05
    }

    MultiEffect {
        id: blurEffect

        visible: root.cfg.blurBackground
        source: background
        anchors.fill: background
        blurEnabled: true
        blurMax: 32
        blur: 0.9
        contrast: 0.05
        saturation: 0.15
    }

    // Dark overlay & Global click/key listener
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: {
            if (!root.isUnlocked)
                root.isUnlocked = true;

            passwordBox.forceActiveFocus();
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.alpha(Colours.palette.surface, 0.4)
        }

    }

    Item {
        focus: true
        Keys.onPressed: (event) => {
            if (!root.isUnlocked)
                root.isUnlocked = true;

            passwordBox.forceActiveFocus();
        }
    }

    // 2. CENTERED IDLE LOCK STATE (Clock & Date dead center at startup)
    ColumnLayout {
        id: centeredHeader

        anchors.centerIn: parent
        spacing: 6
        opacity: root.isUnlocked ? 0 : 1
        visible: opacity > 0

        Text {
            text: Time.time
            color: Colours.palette.on_surface
            font.family: Config.settings.font
            font.pixelSize: 104
            font.weight: 800
            Layout.alignment: Qt.AlignHCenter
            style: Text.Outline
            styleColor: Qt.alpha("black", 0.3)
        }

        Text {
            text: Time.fullDate
            color: Qt.alpha(Colours.palette.on_surface, 0.9)
            font.family: Config.settings.font
            font.pixelSize: 32
            font.weight: 600
            Layout.alignment: Qt.AlignHCenter
            style: Text.Outline
            styleColor: Qt.alpha("black", 0.3)
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
            }

        }

    }

    // Unlock Prompt (Visible at startup below centered clock)
    Item {
        id: unlockPrompt

        width: 340
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
            color: Qt.alpha(Colours.palette.on_surface, 0.85)
            font.family: Config.settings.font
            font.pixelSize: 16
            font.weight: 500

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

    Item {
        id: idleMediaWrapper

        width: 400
        height: 96
        visible: root.cfg.showMedia && !root.isUnlocked
        opacity: root.isUnlocked ? 0 : 1

        anchors {
            left: parent.left
            bottom: parent.bottom
            leftMargin: 36
            bottomMargin: 36
        }

        LockMusic {
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
            }

        }

    }

    // 3. UNLOCKED SIDE-BY-SIDE MAIN LAYOUT (Matches Savior SDDM Theme)
    // LEFT: Clock, Date & Integrated Media Player Card | RIGHT: Login Card & Power Controls
    RowLayout {
        id: mainSideBySideRow

        anchors.centerIn: parent
        spacing: 70
        opacity: root.isUnlocked ? 1 : 0
        scale: root.isUnlocked ? 1 : 0.95
        visible: opacity > 0

        ColumnLayout {
            spacing: 24
            Layout.alignment: Qt.AlignVCenter

            ColumnLayout {
                spacing: 6
                Layout.alignment: Qt.AlignHCenter

                Text {
                    text: Time.time
                    color: Colours.palette.on_surface
                    font.family: Config.settings.font
                    font.pixelSize: 104
                    font.weight: 800
                    Layout.alignment: Qt.AlignHCenter
                    style: Text.Outline
                    styleColor: Qt.alpha("black", 0.3)
                }

                Text {
                    text: Time.fullDate
                    color: Qt.alpha(Colours.palette.on_surface, 0.9)
                    font.family: Config.settings.font
                    font.pixelSize: 32
                    font.weight: 600
                    Layout.alignment: Qt.AlignHCenter
                    style: Text.Outline
                    styleColor: Qt.alpha("black", 0.3)
                }

            }

            // Integrated Media Player Card (Visible when unlocked)
            Item {
                visible: root.cfg.showMedia
                Layout.preferredWidth: 340
                Layout.preferredHeight: 85
                Layout.alignment: Qt.AlignHCenter

                LockMusic {
                }

            }

        }

        // RIGHT COLUMN: Login Card & Power Controls
        ColumnLayout {
            id: formContainer

            spacing: 16
            Layout.alignment: Qt.AlignVCenter

            // Login Card (Matching Savior SDDM Theme LoginPanel)
            Rectangle {
                id: loginCard

                Layout.preferredWidth: 400
                implicitHeight: loginColumn.implicitHeight + 48
                radius: Math.max(4, Config.settings.borderRadius)
                color: Qt.alpha(Colours.palette.surface, 0.85)
                border.color: root.context.showFailure ? Colours.palette.error : Qt.alpha(Colours.palette.outline, 0.25)
                border.width: 1

                ColumnLayout {
                    id: loginColumn

                    spacing: 18

                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        topMargin: 24
                        leftMargin: 24
                        rightMargin: 24
                    }

                    // User Profile Avatar & Username
                    ColumnLayout {
                        spacing: 10
                        Layout.alignment: Qt.AlignHCenter

                        ClippingWrapperRectangle {
                            radius: 1000
                            Layout.preferredWidth: 84
                            Layout.preferredHeight: 84
                            Layout.alignment: Qt.AlignHCenter
                            color: Colours.palette.primary_container

                            IconImage {
                                anchors.fill: parent
                                source: {
                                    let loc = Config.settings.pfpLocation || "~/.face";
                                    let path = loc.startsWith("/") ? loc : `${Quickshell.env("HOME")}/${loc.replace(/^~\//, "")}`;
                                    return `file://${path}`;
                                }
                                onStatusChanged: {
                                    if (status === Image.Error)
                                        source = Qt.resolvedUrl(Quickshell.shellDir + "/assets/icon.png");

                                }
                            }

                        }

                        Rectangle {
                            implicitWidth: nameText.implicitWidth + 28
                            implicitHeight: 32
                            radius: 16
                            color: Colours.palette.surface_container
                            border.color: Qt.alpha(Colours.palette.outline, 0.2)
                            border.width: 1
                            Layout.alignment: Qt.AlignHCenter

                            Text {
                                id: nameText

                                anchors.centerIn: parent
                                text: User.username ? User.username : "User"
                                color: Colours.palette.on_surface
                                font.family: Config.settings.font
                                font.pixelSize: 14
                                font.weight: 700
                            }

                        }

                    }

                    // Floating Error Tooltip Pill
                    Rectangle {
                        visible: root.context.showFailure
                        opacity: root.context.showFailure ? 1 : 0
                        implicitWidth: errorRow.implicitWidth + 24
                        implicitHeight: 32
                        radius: 16
                        color: Colours.palette.error
                        Layout.alignment: Qt.AlignHCenter

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
                                font.weight: 700
                            }

                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 150
                            }

                        }

                    }

                    // Password Input Container
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 48
                        radius: 24
                        color: Colours.palette.surface_container
                        border.color: passwordBox.activeFocus ? Colours.palette.primary : Qt.alpha(Colours.palette.outline, 0.2)
                        border.width: passwordBox.activeFocus ? 2 : 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            spacing: 8

                            Text {
                                text: "lock"
                                font.family: Config.settings.iconFont
                                font.pixelSize: 18
                                color: passwordBox.activeFocus ? Colours.palette.primary : Qt.alpha(Colours.palette.on_surface, 0.6)
                            }

                            TextField {
                                id: passwordBox

                                focus: true
                                Layout.fillWidth: true
                                echoMode: root.revealPassword ? TextInput.Normal : TextInput.Password
                                passwordCharacter: "•"
                                color: Colours.palette.on_surface
                                selectionColor: Colours.palette.primary
                                selectedTextColor: Colours.palette.on_primary
                                font.family: Config.settings.font
                                font.pixelSize: 15
                                font.weight: 500
                                verticalAlignment: Text.AlignVCenter
                                placeholderText: "Password..."
                                placeholderTextColor: Qt.alpha(Colours.palette.on_surface, 0.4)
                                onTextChanged: {
                                    if (root.context.currentText !== text)
                                        root.context.currentText = text;

                                }
                                onAccepted: {
                                    root.context.tryUnlock();
                                }

                                Connections {
                                    function onCurrentTextChanged() {
                                        if (passwordBox.text !== root.context.currentText)
                                            passwordBox.text = root.context.currentText;

                                    }

                                    target: root.context
                                }

                            }

                            // Eye Reveal Toggle Button
                            Rectangle {
                                id: eyeBtn

                                property bool hovered: false

                                width: 32
                                height: 32
                                radius: 16
                                color: hovered ? Colours.palette.surface_container_highest : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: root.revealPassword ? "visibility_off" : "visibility"
                                    font.family: Config.settings.iconFont
                                    font.pixelSize: 18
                                    color: root.revealPassword ? Colours.palette.primary : Qt.alpha(Colours.palette.on_surface, 0.6)
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

                    // Unlock Action Button
                    Rectangle {
                        id: unlockBtn

                        property bool hovered: false
                        property bool pressed: false

                        Layout.fillWidth: true
                        implicitHeight: 46
                        radius: 23
                        color: pressed ? Qt.alpha(Colours.palette.primary, 0.7) : (hovered ? Qt.alpha(Colours.palette.primary, 0.9) : Colours.palette.primary)
                        border.color: Colours.palette.primary
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: "UNLOCK"
                                color: Colours.palette.on_primary
                                font.family: Config.settings.font
                                font.pixelSize: 13
                                font.weight: 800
                                font.letterSpacing: 1.5
                            }

                            Text {
                                text: "arrow_forward"
                                font.family: Config.settings.iconFont
                                font.pixelSize: 18
                                color: Colours.palette.on_primary
                            }

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

            // Quick Actions & Power Bar (Matching Savior SDDM Theme PowerBar)
            Rectangle {
                id: powerBar

                Layout.preferredWidth: 380
                implicitHeight: 64
                radius: 32
                color: Qt.alpha(Colours.palette.surface, 0.85)
                border.color: Qt.alpha(Colours.palette.outline, 0.25)
                border.width: 1

                RowLayout {
                    spacing: 10

                    anchors {
                        fill: parent
                        leftMargin: 14
                        rightMargin: 14
                    }

                    // System Metrics Pill
                    Rectangle {
                        visible: root.cfg.showSystemPill
                        Layout.fillWidth: true
                        implicitHeight: 40
                        radius: Config.settings.borderRadius ? Config.settings.borderRadius : 20
                        color: Colours.palette.surface_container

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 12

                            Text {
                                text: Config.settings.notifications && Config.settings.notifications.doNotDisturb ? "notifications_off" : "notifications"
                                font.family: Config.settings.iconFont
                                font.pixelSize: 18
                                color: Qt.alpha(Colours.palette.on_surface, 0.8)
                            }

                            QuickStatusGroup {
                                showClock: false
                                showNetwork: true
                                showBluetooth: true
                                showBattery: true
                                showBatteryPercentage: true
                                contentColor: Colours.palette.on_surface
                                iconPixelSize: 18
                            }

                        }

                    }

                    // Suspend Button
                    Rectangle {
                        id: suspBtn

                        property bool hovered: false

                        width: 40
                        height: 40
                        radius: 20
                        color: hovered ? Colours.palette.surface_container_highest : Colours.palette.surface_container
                        border.color: Qt.alpha(Colours.palette.outline, 0.15)
                        border.width: 1

                        Text {
                            text: "bedtime"
                            font.family: Config.settings.iconFont
                            font.pixelSize: 18
                            color: Colours.palette.on_surface
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

                        width: 40
                        height: 40
                        radius: 20
                        color: hovered ? Colours.palette.surface_container_highest : Colours.palette.surface_container
                        border.color: Qt.alpha(Colours.palette.outline, 0.15)
                        border.width: 1

                        Text {
                            text: "restart_alt"
                            font.family: Config.settings.iconFont
                            font.pixelSize: 18
                            color: Colours.palette.on_surface
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

                        visible: root.cfg.showPowerBtn
                        width: 40
                        height: 40
                        radius: 20
                        color: hovered ? Colours.palette.error : Colours.palette.surface_container
                        border.color: hovered ? Colours.palette.error : Qt.alpha(Colours.palette.outline, 0.15)
                        border.width: 1

                        Text {
                            text: "power_settings_new"
                            font.family: Config.settings.iconFont
                            font.pixelSize: 18
                            color: powerBtn.hovered ? Colours.palette.on_error : Colours.palette.on_surface
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

        }

        Behavior on opacity {
            NumberAnimation {
                duration: 400
            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutBack
            }

        }

    }

    // Shake animation on incorrect password
    Connections {
        function onShowFailureChanged() {
            if (root.context.showFailure)
                shakeAnim.restart();

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
