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

StyledRect {
    id: root

    required property LockContext context
    // Reactive Lockscreen Settings & Border Radius bindings from Config
    readonly property bool showClock: Config.get("lockscreen.showClock", true)
    readonly property bool showDate: Config.get("lockscreen.showDate", true)
    readonly property bool blurBackground: Config.get("lockscreen.blurBackground", true)
    readonly property bool showMedia: Config.get("lockscreen.showMedia", true)
    readonly property bool showSystemPill: Config.get("lockscreen.showSystemPill", true)
    readonly property bool showPowerBtn: Config.get("lockscreen.showPowerBtn", true)
    readonly property real configBorderRadius: Config.get("borderRadius", 4)
    readonly property real cardRadius: root.configBorderRadius
    readonly property Theme
    theme: Theme {
        primary: Colours.palette.primary
        on_primary: Colours.palette.on_primary
        primaryContainer: Colours.palette.primary_container
        on_primary_container: Colours.palette.on_primary_container
        primaryFixedDim: Colours.palette.primary_fixed_dim
        error: Colours.palette.error
        on_error: Colours.palette.on_error
        on_surface: Colours.palette.on_surface
        on_surface_variant: Colours.palette.on_surface_variant
        surfaceContainerHigh: Colours.palette.surface_container_high
        fontFamily: Config.get("font", "SF Pro Display")
        iconFontFamily: (iconFontLoader.status === FontLoader.Ready && iconFontLoader.name !== "") ? iconFontLoader.name : Config.get("iconFont", "Material Symbols Rounded")
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
        let usePfp = Config.get("usePfpInsteadOfLogo", true);
        if (usePfp) {
            let loc = Config.get("pfpLocation", "~/.face");
            let path = loc.startsWith("/") ? loc : `${Quickshell.env("HOME")}/${loc.replace(/^~\//, "")}`;
            return `file://${path}`;
        }
        return "";
    }

    function activateLogin() {
        root.isUnlocked = true;
        loginPill.focusPassword();
    }

    variant: "common"
    useDefaultRadius: false
    color: Colours.palette.background

    FontLoader {
        id: iconFontLoader

        source: Qt.resolvedUrl(Quickshell.shellDir + "/assets/fonts/MaterialSymbolsRounded.ttf")
    }

    Image {
        id: background

        anchors.fill: parent
        source: Config.get("currentWallpaper", "")
        sourceSize: Qt.size(width > 0 ? width : Screen.width, height > 0 ? height : Screen.height)
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

        StyledRect {
            variant: "internalbg"
            useDefaultRadius: false
            border.width: 0
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
            font.family: Config.get("font", "SF Pro Display")
            font.pixelSize: Styling.fontSize.lg
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

        spacing: Styling.spacing.xxxl
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
            userName: (typeof User !== "undefined" && User && User.username) ? User.username : "user"
            userLogin: (typeof User !== "undefined" && User && User.username) ? User.username : "user"
            errorMessage: root.context.showFailure ? "Incorrect password" : ""
            avatarPath: root.avatarPath
            avatarFallback: Qt.resolvedUrl(Quickshell.shellDir + "/assets/icon.png")
            canSwitchUser: false
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

        StyledRect {
            variant: "internalbg"
            useDefaultRadius: false
            implicitHeight: 40
            radius: Math.max(2, root.theme.cardRadius - 2)
            color: root.theme.pillColor
            border.color: root.theme.pillBorderColor
            border.width: 1

            RowLayout {
                anchors.centerIn: parent
                spacing: Styling.spacing.lg

                Text {
                    text: Config.get("notifications.doNotDisturb", false) ? "notifications_off" : "notifications"
                    font.family: Config.get("iconFont", "Material Symbols Rounded")
                    font.pixelSize: Styling.fontSize.headline
                    color: Qt.rgba(1, 1, 1, 0.8)
                }

                QuickStatusGroup {
                    showClock: false
                    showNetwork: true
                    showBluetooth: true
                    contentColor: Qt.rgba(1, 1, 1, 0.9)
                    iconPixelSize: Styling.fontSize.headline
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
