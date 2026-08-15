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
import qs.features.settings
import qs.features.settings.content
import qs.features.settings.content.generics
import qs.services

Item {
    id: root

    Item {
        id: pageWrapper

        width: parent.width - 30
        height: parent.height - 60
        anchors.top: parent.top
        anchors.topMargin: (parent.height / 2) - (height / 2)
        anchors.left: parent.left
        anchors.leftMargin: (parent.width / 2) - (width / 2)

        ScrollView {
            anchors.fill: parent
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                width: pageWrapper.width - 20
                spacing: 12

                GenericTitle {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    Layout.preferredHeight: 20
                    Layout.topMargin: 10
                    text: "Lockscreen"
                    iconCode: "lock"
                }

                GenericSeperator {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.topMargin: 5
                    Layout.preferredWidth: pageWrapper.width
                    Layout.preferredHeight: 3
                }

                GenericToggleOption {
                    message: "Blur Desktop Background"
                    option: Config.settings.lockscreen.blurBackground
                    toRun: () => {
                        let val = !Config.settings.lockscreen.blurBackground;
                        Config.updateKey("lockscreen.blurBackground", val);
                        return val;
                    }
                    withIcon: true
                    iconCode: "blur_on"
                }

                GenericToggleOption {
                    message: "Show Clock Header"
                    option: Config.settings.lockscreen.showClock
                    toRun: () => {
                        let val = !Config.settings.lockscreen.showClock;
                        Config.updateKey("lockscreen.showClock", val);
                        return val;
                    }
                    withIcon: true
                    iconCode: "schedule"
                }

                GenericToggleOption {
                    message: "Show Date Subtitle"
                    option: Config.settings.lockscreen.showDate
                    toRun: () => {
                        let val = !Config.settings.lockscreen.showDate;
                        Config.updateKey("lockscreen.showDate", val);
                        return val;
                    }
                    withIcon: true
                    iconCode: "calendar_today"
                }

                GenericToggleOption {
                    message: "Show Media Player Pill"
                    option: Config.settings.lockscreen.showMedia
                    toRun: () => {
                        let val = !Config.settings.lockscreen.showMedia;
                        Config.updateKey("lockscreen.showMedia", val);
                        return val;
                    }
                    withIcon: true
                    iconCode: "graphic_eq"
                }

                GenericToggleOption {
                    message: "Show System Status Pill"
                    option: Config.settings.lockscreen.showSystemPill
                    toRun: () => {
                        let val = !Config.settings.lockscreen.showSystemPill;
                        Config.updateKey("lockscreen.showSystemPill", val);
                        return val;
                    }
                    withIcon: true
                    iconCode: "info"
                }

                GenericToggleOption {
                    message: "Show Power Button"
                    option: Config.settings.lockscreen.showPowerBtn
                    toRun: () => {
                        let val = !Config.settings.lockscreen.showPowerBtn;
                        Config.updateKey("lockscreen.showPowerBtn", val);
                        return val;
                    }
                    withIcon: true
                    iconCode: "power_settings_new"
                }

                GenericSeperator {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.topMargin: 5
                    Layout.preferredWidth: pageWrapper.width
                    Layout.preferredHeight: 1
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 5

                    StyledRect {
                        id: testLockBtn

                        property bool hovered: false

                        variant: "focus"
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 40
                        radius: Config.settings.borderRadius - 8
                        color: hovered ? Colours.palette.primary : Qt.alpha(Colours.palette.primary, 0.85)

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: Styling.spacing.lg

                            Text {
                                text: "lock_open"
                                font.family: Config.settings.iconFont
                                font.pixelSize: Styling.fontSize.title
                                color: Colours.palette.on_primary
                            }

                            Text {
                                text: "Test Lockscreen"
                                font.family: Config.settings.font
                                font.pixelSize: Styling.fontSize.body
                                font.weight: 600
                                color: Colours.palette.on_primary
                            }

                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: testLockBtn.hovered = true
                            onExited: testLockBtn.hovered = false
                            onClicked: IPCLoader.toggleLockscreen()
                        }

                        Behavior on color {
                            PropertyAnimation {
                                duration: 150
                                easing.type: Easing.InSine
                            }

                        }

                    }

                }

            }

        }

    }

}
