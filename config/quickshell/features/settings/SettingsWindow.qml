import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.core
import qs.features
import qs.features.common
import qs.features.settings
import qs.services

Loader {
    id: root

    required property bool isSettingsWindowOpen
    property int winWidth: 1200
    property int winHeight: 700
    property bool ani

    active: false
    onIsSettingsWindowOpenChanged: {
        if (root.isSettingsWindowOpen == true) {
            root.active = true;
            root.ani = true;
        } else {
            root.ani = false;
        }
    }

    sourceComponent: Scope {
        signal finished()

        Variants {
            model: Quickshell.screens

            PanelWindow {
                id: settingsWindow

                property var modelData

                screen: modelData
                aboveWindows: true
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                visible: true
                focusable: true
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

                anchors {
                    bottom: true
                    left: true
                    top: true
                    right: true
                }

                ScrollView {
                    id: maskId

                    implicitHeight: root.winHeight
                    implicitWidth: root.winWidth
                    anchors.leftMargin: (parent.width / 2) - (width / 2)
                    anchors.bottomMargin: -1 * root.winHeight
                    opacity: 0
                    clip: true

                    anchors {
                        bottom: parent.bottom
                        top: undefined
                        left: parent.left
                        right: undefined
                    }

                    Timer {
                        running: root.ani
                        repeat: false
                        interval: 20
                        onTriggered: {
                            maskId.anchors.bottomMargin = (settingsWindow.height / 2) - (maskId.height / 2);
                            maskId.opacity = 1;
                        }
                    }

                    Timer {
                        running: !root.ani
                        repeat: false
                        interval: 1
                        onTriggered: {
                            maskId.anchors.bottomMargin = -1 * root.winHeight;
                            maskId.opacity = 0;
                        }
                    }

                    Timer {
                        running: !root.ani
                        repeat: false
                        interval: 250
                        onTriggered: {
                            root.active = false;
                        }
                    }

                    Rectangle {
                        readonly property var sectionTitles: ["Desktop", "Bar", "Theming", "Notifications", "Lockscreen", "Services & Extras", "Components", "About"]
                        readonly property string currentSection: sectionTitles[SettingsControl.settingsLocation] || ""

                        anchors.fill: parent
                        color: Colours.palette.surface
                        radius: Config.settings.borderRadius

                        Text {
                            id: windowIcon

                            text: "settings"
                            font.family: Config.settings.iconFont
                            font.pixelSize: 18
                            color: Qt.alpha(Colours.palette.on_surface, 0.8)
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.topMargin: 14
                            anchors.leftMargin: 20
                        }

                        RowLayout {
                            anchors.top: parent.top
                            anchors.left: windowIcon.right
                            anchors.topMargin: 14
                            anchors.leftMargin: 10
                            spacing: 6

                            Text {
                                text: "Settings"
                                font.family: Config.settings.font
                                font.pixelSize: 16
                                font.weight: 600
                                color: Colours.palette.on_surface
                            }

                            Text {
                                text: "•"
                                font.family: Config.settings.font
                                font.pixelSize: 16
                                color: Qt.alpha(Colours.palette.on_surface, 0.4)
                            }

                            Text {
                                text: parent.parent.currentSection
                                font.family: Config.settings.font
                                font.pixelSize: 15
                                font.weight: 500
                                color: Colours.palette.primary
                            }

                        }

                        Rectangle {
                            id: closeBtn

                            property bool hovered: false

                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.topMargin: 10
                            anchors.rightMargin: 15
                            color: hovered ? Colours.palette.surface_container_highest : Colours.palette.surface_container
                            radius: Math.max(4, Config.settings.borderRadius - 10)
                            width: 32
                            height: 32

                            Text {
                                anchors.centerIn: parent
                                text: "close"
                                font.family: Config.settings.iconFont
                                font.pixelSize: 18
                                color: closeBtn.hovered ? Qt.alpha(Colours.palette.on_surface, 0.9) : Qt.alpha(Colours.palette.on_surface, 0.6)
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: closeBtn.hovered = true
                                onExited: closeBtn.hovered = false
                                onClicked: IPCLoader.toggleSettings()
                            }

                            Behavior on color {
                                PropertyAnimation {
                                    duration: Config.settings.animationSpeed
                                    easing.type: Easing.InSine
                                }

                            }

                        }

                        RowLayout {
                            anchors.top: parent.top
                            anchors.topMargin: 46
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            spacing: 0

                            SettingsSidebar {
                                id: sidebar

                                Layout.fillHeight: true
                                Layout.preferredWidth: sidebar.collapsed ? 64 : 220
                                Layout.leftMargin: 10
                                Layout.bottomMargin: 10

                                Behavior on Layout.preferredWidth {
                                    PropertyAnimation {
                                        duration: 200
                                        easing.type: Easing.InSine
                                    }

                                }

                            }

                            SettingsContent {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                Layout.rightMargin: 15
                                Layout.bottomMargin: 10
                            }

                        }

                    }

                    Behavior on anchors.bottomMargin {
                        PropertyAnimation {
                            duration: 200
                            easing.type: Easing.InSine
                        }

                    }

                    Behavior on opacity {
                        PropertyAnimation {
                            duration: Config.settings.animationSpeed
                            easing.type: Easing.InSine
                        }

                    }

                }

                mask: Region {
                    item: maskId
                }

            }

        }

    }

}
