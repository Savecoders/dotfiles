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

        sourceComponent: Rectangle {
            id: overlay

            color: Qt.alpha(Colours.palette.scrim, 0.5)
            opacity: 0
            anchors.fill: parent

            MouseArea {
                anchors.fill: parent
                onClicked: Globals.visibility.powermenu = false
            }

            Rectangle {
                id: menu

                width: 300
                height: 200
                color: Colours.palette.surface_container
                radius: Config.settings.borderRadius
                anchors.centerIn: parent

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    Text {
                        text: "Powermenu"
                        color: Colours.palette.on_surface
                        font.family: Config.settings.font
                        font.pixelSize: 18
                        font.weight: 600
                        Layout.alignment: Qt.AlignHCenter
                    }

                    RowLayout {
                        spacing: 8
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

                            delegate: Rectangle {
                                property bool hovered: false

                                implicitWidth: 60
                                implicitHeight: 70
                                color: hovered ? Colours.palette.surface_container_high : "transparent"
                                radius: Config.settings.borderRadius

                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 4

                                    Text {
                                        text: modelData.icon
                                        color: hovered ? Colours.palette.primary : Colours.palette.on_surface
                                        font.family: Config.settings.iconFont
                                        font.pixelSize: 24
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
                                        font.pixelSize: 10
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
