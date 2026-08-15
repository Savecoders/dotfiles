import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.core
import qs.features.common

Scope {
    id: root

    property bool open: Globals.visibility.powermenu

    onOpenChanged: {
        if (open) {
            loader.active = true;
            animIn.start();
        } else {
            animOut.start();
        }
    }

    SequentialAnimation {
        id: animIn

        running: false

        PropertyAction {
            target: loader
            property: "active"
            value: true
        }

        PropertyAnimation {
            target: overlay
            property: "opacity"
            from: 0
            to: 1
            duration: 150
            easing.type: Easing.InSine
        }

    }

    SequentialAnimation {
        id: animOut

        running: false

        PropertyAnimation {
            target: overlay
            property: "opacity"
            from: 1
            to: 0
            duration: 100
            easing.type: Easing.OutSine
        }

        PropertyAction {
            target: loader
            property: "active"
            value: false
        }

    }

    Loader {
        id: loader

        active: false

        sourceComponent: StyledRect {
            id: overlay

            variant: "pane"
            useDefaultRadius: false
            border.width: 0
            radius: 0
            color: Qt.alpha(Colours.palette.scrim, 0.5)
            opacity: 0
            anchors.fill: parent

            MouseArea {
                anchors.fill: parent
                onClicked: Globals.visibility.powermenu = false
            }

            StyledRect {
                id: menu

                variant: "popup"
                width: 300
                height: 200
                color: Colours.palette.surface_container
                radius: Config.settings.borderRadius
                anchors.centerIn: parent

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Styling.spacing.xl
                    spacing: Styling.spacing.lg

                    Text {
                        text: "Powermenu"
                        color: Colours.palette.on_surface
                        font.family: Config.settings.font
                        font.pixelSize: Styling.fontSize.title
                        font.weight: 600
                        Layout.alignment: Qt.AlignHCenter
                    }

                    RowLayout {
                        spacing: Styling.spacing.lg
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter

                        Repeater {
                            model: [{
                                "icon": "lock",
                                "label": "Lock",
                                "cmd": "loginctl lock-session"
                            }, {
                                "icon": "power_settings_new",
                                "label": "Suspend",
                                "cmd": "systemctl suspend"
                            }, {
                                "icon": "refresh",
                                "label": "Reboot",
                                "cmd": "systemctl reboot"
                            }, {
                                "icon": "power_off",
                                "label": "Shutdown",
                                "cmd": "systemctl poweroff"
                            }]

                            delegate: StyledRect {
                                property bool hovered: false

                                variant: hovered ? "internalbg" : "common"
                                implicitWidth: 60
                                implicitHeight: 70
                                color: hovered ? Colours.palette.surface_container_high : "transparent"
                                radius: Config.settings.borderRadius

                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: Styling.spacing.sm

                                    Text {
                                        text: modelData.icon
                                        color: hovered ? Colours.palette.primary : Colours.palette.on_surface
                                        font.family: Config.settings.iconFont
                                        font.pixelSize: Styling.fontSize.xxl
                                        Layout.alignment: Qt.AlignHCenter

                                        Behavior on color {
                                            PropertyAnimation {
                                                duration: 100
                                                easing.type: Easing.InSine
                                            }

                                        }

                                    }

                                    Text {
                                        text: modelData.label
                                        color: Colours.palette.on_surface_variant
                                        font.family: Config.settings.font
                                        font.pixelSize: Styling.fontSize.xs
                                        Layout.alignment: Qt.AlignHCenter
                                    }

                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: parent.hovered = true
                                    onExited: parent.hovered = false
                                    onClicked: {
                                        Quickshell.execDetached(["bash", "-c", modelData.cmd]);
                                        Globals.visibility.powermenu = false;
                                    }
                                }

                                Behavior on color {
                                    PropertyAnimation {
                                        duration: 100
                                        easing.type: Easing.InSine
                                    }

                                }

                            }

                        }

                    }

                }

            }

        }

    }

}
