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
import qs.features.common.lock
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

    FontLoader {
        id: iconFontLoader
        source: Qt.resolvedUrl(Quickshell.shellDir + "/assets/fonts/MaterialSymbolsRounded.ttf")
    }

    readonly property Theme theme: Theme {
        primary: Colours.palette.primary ? Colours.palette.primary : "#87d6bd"
        on_primary: Colours.palette.on_primary ? Colours.palette.on_primary : "#00382c"
        primaryContainer: Colours.palette.primary_container ? Colours.palette.primary_container : "#005141"
        on_primary_container: Colours.palette.on_primary_container ? Colours.palette.on_primary_container : "#a2f2d8"
        primaryFixedDim: Colours.palette.primary_fixed_dim ? Colours.palette.primary_fixed_dim : "#90d1de"
        error: Colours.palette.error ? Colours.palette.error : "#ffb4ab"
        on_error: Colours.palette.on_error ? Colours.palette.on_error : "#690005"
        on_surface: Colours.palette.on_surface ? Colours.palette.on_surface : "#dee4e0"
        on_surface_variant: Colours.palette.on_surface_variant ? Colours.palette.on_surface_variant : "#bfc9c4"
        surfaceContainerHigh: Colours.palette.surface_container_high ? Colours.palette.surface_container_high : "#252b29"
        fontFamily: Config.settings.font
        iconFontFamily: (iconFontLoader.status === FontLoader.Ready && iconFontLoader.name !== "") ? iconFontLoader.name : (Config.settings.iconFont ? Config.settings.iconFont : "Material Symbols Rounded")
        cardRadius: root.configBorderRadius
        cardColor: Qt.rgba(0, 0, 0, 0.5)
        cardBorderColor: Qt.rgba(1, 1, 1, 0.15)
        inputColor: Qt.rgba(0, 0, 0, 0.4)
        inputBorderColor: Qt.rgba(1, 1, 1, 0.12)
        pillColor: Qt.rgba(0, 0, 0, 0.35)
        pillBorderColor: Qt.rgba(1, 1, 1, 0.1)
        hoverOverlay: Qt.rgba(1, 1, 1, 0.2)
    }

    property bool isUnlocked: false
    property string avatarPath: {
        let usePfp = Config.settings && Config.settings.usePfpInsteadOfLogo !== undefined ? Config.settings.usePfpInsteadOfLogo : true;
        if (usePfp) {
            let loc = Config.settings.pfpLocation || "~/.face";
            let path = loc.startsWith("/") ? loc : `${Quickshell.env("HOME")}/${loc.replace(/^~\//, "")}`;
            return `file://${path}`;
        }
        return "";
    }

    color: Colours.palette.background

    function activateLogin() {
        root.isUnlocked = true;
        loginPill.focusPassword();
    }

    Image {
        id: background

        anchors.fill: parent
        source: Config.settings.currentWallpaper
        fillMode: Image.PreserveAspectCrop
        asynchronous: false
        cache: false
        scale: 1.05
        visible: !root.blurBackground
    }

    MultiEffect {
        id: blurEffect

        anchors.fill: parent
        visible: root.blurBackground
        source: background
        blurEnabled: true
        blurMax: 32
        blur: 1
    }

    // Dark Overlay & Global Click/Key Listener
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: root.activateLogin()

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.4)
        }

    }

    Item {
        focus: true
        Keys.onPressed: (event) => {
            root.activateLogin();
        }
    }

    // Center Clock & Date Header (Optional)
    ClockHeader {
        id: centeredHeader

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -60
        theme: root.theme
        showClock: root.showClock
        showDate: root.showDate
        clockFormat: "HH:mm"
        dateFormat: "dddd, MMMM d"
    }


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

    // Active Bottom Bar (Music Card + Login Pill + Power Pill)
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
        // Music card left
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

        LoginPill {
            id: loginPill

            theme: root.theme
            errorMessage: root.context.showFailure ? "Incorrect password" : ""
            avatarPath: root.avatarPath
            avatarFallback: Qt.resolvedUrl(Quickshell.shellDir + "/assets/icon.png")
            onLoginRequested: root.context.tryUnlock()
            onPasswordChanged: {
                if (root.context.currentText !== loginPill.password)
                    root.context.currentText = loginPill.password;

            }
        }

        PowerPill {
            id: powerPill

            theme: root.theme
            statusComponent: systemStatus
            showStatus: root.showSystemPill
            showPowerBtn: root.showPowerBtn
            onSuspendClicked: Quickshell.execDetached(["systemctl", "suspend"])
            onRebootClicked: Quickshell.execDetached(["systemctl", "reboot"])
            onPowerOffClicked: Quickshell.execDetached(["wlogout"])
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

    // Quickshell-only status component
    Component {
        id: systemStatus

        Rectangle {
            implicitHeight: 40
            radius: Math.max(2, root.theme.cardRadius - 2)
            color: root.theme.pillColor
            border.color: root.theme.pillBorderColor
            border.width: 1

            RowLayout {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    text: Config.settings.notifications && Config.settings.notifications.doNotDisturb ? "notifications_off" : "notifications"
                    font.family: Config.settings.iconFont
                    font.pixelSize: 20
                    color: Qt.rgba(1, 1, 1, 0.8)
                }

                QuickStatusGroup {
                    showClock: false
                    showNetwork: true
                    showBluetooth: true
                    showBattery: true
                    showBatteryPercentage: true
                    contentColor: Qt.rgba(1, 1, 1, 0.9)
                    iconPixelSize: 20
                }

            }

        }

    }

    // Two-way password sync with the LockContext
    Connections {
        function onCurrentTextChanged() {
            if (loginPill.password !== root.context.currentText)
                loginPill.password = root.context.currentText;

        }

        function onShowFailureChanged() {
            if (root.context.showFailure && !root.isUnlocked)
                root.isUnlocked = true;

        }

        target: root.context
    }

}
