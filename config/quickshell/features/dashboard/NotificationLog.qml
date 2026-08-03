import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls
import Quickshell.Widgets
import qs.core
import qs.features.common
import qs.services

Rectangle {
    id: root

    property int notificationCount: Notifications.list.length

    anchors.fill: parent
    radius: Config.settings.borderRadius
    color: Colours.palette.surface
    clip: true

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 20
            Layout.leftMargin: 20
            Layout.rightMargin: 20

            Text {
                color: Colours.palette.on_surface
                text: "Notifications"
                font.family: Config.settings.font
                font.pixelSize: 18
                font.weight: 700
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                id: clearBtn

                property bool isHovered: false

                Layout.preferredWidth: 90
                Layout.preferredHeight: 34
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                radius: isHovered ? Math.max(4, Config.settings.borderRadius - 10) : Math.max(4, Config.settings.borderRadius - 6)
                color: isHovered ? Colours.palette.primary : Colours.palette.surface_container

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        color: clearBtn.isHovered ? Colours.palette.on_primary : Colours.palette.on_surface
                        text: "clear_all"
                        font.family: Config.settings.iconFont
                        font.pixelSize: 18

                        Behavior on color {
                            PropertyAnimation {
                                duration: Config.settings.animationSpeed
                                easing.type: Easing.InSine
                            }
                        }
                    }

                    Text {
                        color: clearBtn.isHovered ? Colours.palette.on_primary : Colours.palette.on_surface
                        text: "Clear"
                        font.family: Config.settings.font
                        font.pixelSize: 13
                        font.weight: 600

                        Behavior on color {
                            PropertyAnimation {
                                duration: Config.settings.animationSpeed
                                easing.type: Easing.InSine
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: Notifications.discardAllNotifications()
                    onEntered: clearBtn.isHovered = true
                    onExited: clearBtn.isHovered = false
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
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            Layout.topMargin: 10
            Layout.bottomMargin: 15
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff

            ListView {
                id: notifList

                width: parent.width
                implicitWidth: parent.width
                clip: true
                spacing: 12

                model: ScriptModel {
                    values: [...Notifications.list].reverse()
                }

                add: Transition {
                    NumberAnimation {
                        duration: 300
                        easing.bezierCurve: Anim.standard
                        from: 200
                        property: "x"
                    }
                }

                addDisplaced: Transition {
                    NumberAnimation {
                        duration: 300
                        easing.bezierCurve: Anim.standard
                        properties: "x,y"
                    }
                }

                delegate: SingleNotification {
                    required property Notifications.Notif modelData
                    width: notifList.width
                }

                remove: Transition {
                    NumberAnimation {
                        duration: 300
                        easing.bezierCurve: Anim.standard
                        property: "x"
                        to: 200
                    }
                }

                removeDisplaced: Transition {
                    NumberAnimation {
                        duration: 300
                        easing.bezierCurve: Anim.standard
                        properties: "x,y"
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.centerIn: parent
        height: 100
        width: 200
        color: "transparent"
        visible: root.notificationCount === 0

        Text {
            anchors.centerIn: parent
            text: "No notifications"
            font.pixelSize: 16
            font.family: Config.settings.font
            font.weight: 500
            color: Qt.alpha(Colours.palette.on_surface, 0.5)
        }
    }
}
