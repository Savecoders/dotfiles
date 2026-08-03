import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.core
import qs.features
import qs.features.common
import qs.features.settings
import qs.features.settings.content
import qs.features.settings.content.generics
import qs.services

Rectangle {
    id: root

    color: "transparent"

    Rectangle {
        id: pageWrapper

        width: parent.width - 30
        height: parent.height - 60
        anchors.top: parent.top
        anchors.topMargin: (parent.height / 2) - (height / 2)
        anchors.left: parent.left
        anchors.leftMargin: (parent.width / 2) - (width / 2)
        color: "transparent"

        ScrollView {
            anchors.fill: parent
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                width: pageWrapper.width - 20
                spacing: 15

                IconImage {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.preferredWidth: 96
                    Layout.preferredHeight: 96
                    source: Qt.resolvedUrl(Quickshell.shellDir + "/assets/icon.png")
                }

                Text {
                    text: "Quickshell Dotfiles"
                    font.family: Config.settings.font
                    font.pixelSize: 22
                    font.weight: 600
                    color: Colours.palette.on_surface
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "Version " + (Config.settings.shell.version || "1.0.0")
                    font.family: Config.settings.font
                    font.pixelSize: 14
                    color: Qt.alpha(Colours.palette.on_surface, 0.7)
                    Layout.alignment: Qt.AlignHCenter
                }

                GenericSeperator {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.topMargin: 10
                    Layout.preferredWidth: pageWrapper.width
                    Layout.preferredHeight: 3
                }

                Text {
                    text: "Custom Quickshell Desktop Environment setup for Hyprland and AwesomeWM."
                    font.family: Config.settings.font
                    font.pixelSize: 14
                    color: Qt.alpha(Colours.palette.on_surface, 0.8)
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    Layout.preferredWidth: pageWrapper.width - 40
                }

                Item {
                    Layout.preferredHeight: 15
                }

                // Whisker-style Open JSON Config file button
                Rectangle {
                    id: openJsonBtn

                    property bool hovered: false

                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 240
                    Layout.preferredHeight: 42
                    radius: Math.max(4, Config.settings.borderRadius - 8)
                    color: hovered ? Colours.palette.surface_container_highest : Colours.palette.surface_container
                    border.color: Qt.alpha(Colours.palette.outline, 0.3)
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: "edit_note"
                            font.family: Config.settings.iconFont
                            font.pixelSize: 20
                            color: Colours.palette.primary
                        }

                        Text {
                            text: "Open Configuration File"
                            font.family: Config.settings.font
                            font.pixelSize: 13
                            font.weight: 600
                            color: Colours.palette.on_surface
                        }

                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: openJsonBtn.hovered = true
                        onExited: openJsonBtn.hovered = false
                        onClicked: {
                            Quickshell.execDetached(["xdg-open", `${Quickshell.env("HOME")}/.config/quickshell/settings/settings.json`]);
                        }
                    }

                    Behavior on color {
                        PropertyAnimation {
                            duration: 150
                        }

                    }

                }

            }

        }

    }

}
