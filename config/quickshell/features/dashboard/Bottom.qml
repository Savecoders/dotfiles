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
import qs.features.dashboard.bottom
import qs.services

Rectangle {
    id: root

    property bool isPowerMenuOpen: false

    Layout.fillWidth: true
    Layout.preferredHeight: 45
    implicitHeight: 45
    color: "transparent"

    Rectangle {
        id: powerBtn

        property bool hovered: false

        function getColour() {
            if (root.isPowerMenuOpen)
                return Colours.palette.primary;
            else if (hovered)
                return Colours.palette.primary_container;
            else
                return Colours.palette.surface_container;
        }

        function getTextColour() {
            if (root.isPowerMenuOpen)
                return Colours.palette.on_primary;
            else if (hovered)
                return Colours.palette.on_primary_container;
            else
                return Qt.alpha(Colours.palette.on_surface, 0.8);
        }

        height: 30
        width: hovered ? 47 : 45
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15
        color: getColour()
        radius: hovered ? Math.max(4, Config.settings.borderRadius - 4) : Math.max(4, Config.settings.borderRadius - 8)

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 6
            anchors.top: parent.top
            anchors.topMargin: 5
            text: "mode_off_on"
            font.family: Config.settings.iconFont
            font.pixelSize: 16
            font.weight: 600
            color: powerBtn.getTextColour()

            Behavior on color {
                PropertyAnimation {
                    duration: Config.settings.animationSpeed
                    easing.type: Easing.InSine
                }

            }

        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: 6
            anchors.top: parent.top
            anchors.topMargin: 5
            text: "keyboard_arrow_up"
            font.family: Config.settings.iconFont
            font.pixelSize: 16
            font.weight: 600
            color: powerBtn.getTextColour()
            rotation: root.isPowerMenuOpen ? 0 : 180

            Behavior on rotation {
                PropertyAnimation {
                    duration: Config.settings.animationSpeed
                    easing.type: Easing.InSine
                }

            }

            Behavior on color {
                PropertyAnimation {
                    duration: Config.settings.animationSpeed
                    easing.type: Easing.InSine
                }

            }

        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: powerBtn.hovered = true
            onExited: powerBtn.hovered = false
            onClicked: root.isPowerMenuOpen = !root.isPowerMenuOpen
        }

        Behavior on color {
            PropertyAnimation {
                duration: Config.settings.animationSpeed
                easing.type: Easing.InSine
            }

        }

        Behavior on width {
            PropertyAnimation {
                duration: Config.settings.animationSpeed
                easing.type: Easing.InSine
            }

        }

        Behavior on radius {
            PropertyAnimation {
                duration: Config.settings.animationSpeed
                easing.type: Easing.InSine
            }

        }

    }

    Text {
        anchors.right: settingsBtn.left
        anchors.rightMargin: 10
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 23
        font.family: Config.settings.font
        text: {
            if (Battery.charging) {
                if (Battery.percent == 100)
                    return `${Battery.percent}% (Full)`;
                else
                    return `${Battery.percent}% (Charging)`;
            } else {
                return `${Battery.percent}% (Discharging)`;
            }
        }
        font.pixelSize: 13
        color: Qt.alpha(Colours.palette.on_surface, 0.8)
        Layout.topMargin: 7
    }

    Rectangle {
        id: settingsBtn

        property bool hovered: false

        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15
        anchors.right: parent.right
        anchors.rightMargin: 0
        height: 30
        width: 30
        color: hovered ? Colours.palette.surface_container_high : Colours.palette.surface_container
        radius: hovered ? Math.max(4, Config.settings.borderRadius - 4) : Math.max(4, Config.settings.borderRadius - 8)

        Text {
            anchors.centerIn: parent
            text: "settings"
            font.family: Config.settings.iconFont
            font.pixelSize: 16
            color: settingsBtn.hovered ? Colours.palette.on_surface : Qt.alpha(Colours.palette.on_surface, 0.8)

            Behavior on color {
                PropertyAnimation {
                    duration: Config.settings.animationSpeed
                    easing.type: Easing.InSine
                }

            }

        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: settingsBtn.hovered = true
            onExited: settingsBtn.hovered = false
            onClicked: {
                if (IPCLoader.isSettingsOpen === false)
                    IPCLoader.toggleDashboard();

                IPCLoader.toggleSettings();
            }
        }

        Behavior on color {
            PropertyAnimation {
                duration: Config.settings.animationSpeed
                easing.type: Easing.InSine
            }

        }

        Behavior on radius {
            PropertyAnimation {
                duration: Config.settings.animationSpeed
                easing.type: Easing.InSine
            }

        }

    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.isPowerMenuOpen ? 55 : 15
        width: root.isPowerMenuOpen ? 130 : 45
        height: root.isPowerMenuOpen ? 200 : 30
        anchors.left: parent.left
        anchors.leftMargin: 20
        radius: Math.max(4, Config.settings.borderRadius - 6)
        color: Colours.palette.surface_container
        opacity: root.isPowerMenuOpen ? 1 : 0
        visible: height == 30 ? false : true
        border.width: 1
        border.color: Colours.palette.surface_container_high

        MouseArea {
            anchors.fill: parent
            // to prevent clicks or focus going below
            hoverEnabled: true
        }

        ColumnLayout {
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width - 20
            height: parent.height - 20
            anchors.leftMargin: (parent.width - width) / 2
            anchors.topMargin: (parent.height - height) / 2
            visible: parent.opacity == 1
            spacing: 3

            PowerButton {
                iconCode: "lock"
                text: "Lock"
                toRun: () => {
                    return Quickshell.execDetached(["qs", "ipc", "call", "lock", "lock"]);
                }
            }

            PowerButton {
                iconCode: "sleep"
                text: "Suspend"
                toRun: () => {
                    return Quickshell.execDetached(["systemctl", "suspend"]);
                }
            }

            PowerButton {
                iconCode: "replay"
                text: "Restart"
                toRun: () => {
                    return Quickshell.execDetached(["systemctl", "reboot"]);
                }
            }

            PowerButton {
                iconCode: "schedule"
                text: "Hibernate"
                toRun: () => {
                    return Quickshell.execDetached(["echo"]);
                }
            }

            PowerButton {
                iconCode: "mode_off_on"
                text: "Shutdown"
                toRun: () => {
                    return Quickshell.execDetached(["systemctl", "poweroff"]);
                }
            }

        }

        Behavior on opacity {
            PropertyAnimation {
                duration: Config.settings.animationSpeed
                easing.type: Easing.InSine
            }

        }

        Behavior on width {
            PropertyAnimation {
                duration: Config.settings.animationSpeed
                easing.type: Easing.InSine
            }

        }

        Behavior on height {
            PropertyAnimation {
                duration: Config.settings.animationSpeed - 100
                easing.type: Easing.InSine
            }

        }

        Behavior on anchors.bottomMargin {
            PropertyAnimation {
                duration: Config.settings.animationSpeed
                easing.type: Easing.InSine
            }

        }

    }

}
