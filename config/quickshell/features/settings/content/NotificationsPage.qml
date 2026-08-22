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
                    text: "Notifications"
                    iconCode: "notifications_active"
                }

                GenericSeperator {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.topMargin: 5
                    Layout.preferredWidth: pageWrapper.width
                    Layout.preferredHeight: 3
                }

                GenericToggleOption {
                    message: "Enable Notifications"
                    option: Config.get("notifications.enabled", true)
                    toRun: () => {
                        let val = !Config.get("notifications.enabled", true);
                        Config.updateKey("notifications.enabled", val);
                        return val;
                    }
                    withIcon: true
                    iconCode: "notifications"
                }

                GenericToggleOption {
                    message: "Do Not Disturb"
                    option: Config.get("notifications.doNotDisturb", false)
                    toRun: () => {
                        Notifications.toggleDND();
                        return Config.get("notifications.doNotDisturb", false);
                    }
                    withIcon: true
                    iconCode: "do_not_disturb_on"
                }

                GenericSelectOption {
                    message: "Notification Position"
                    options: ["top-right", "top-left", "top-center", "bottom-right", "bottom-left", "bottom-center"]
                    currentIndex: {
                        let pos = Config.get("notifications.position", "top-right");
                        let idx = ["top-right", "top-left", "top-center", "bottom-right", "bottom-left", "bottom-center"].indexOf(pos);
                        return idx !== -1 ? idx : 0;
                    }
                    toRun: (index) => {
                        let list = ["top-right", "top-left", "top-center", "bottom-right", "bottom-left", "bottom-center"];
                        let selected = list[index];
                        Config.updateKey("notifications.position", selected);
                    }
                    withIcon: true
                    iconCode: "vertical_align_bottom"
                }

                GenericNumberOption {
                    message: "Max Visible Popups"
                    value: Config.get("notifications.maxVisiblePopups", 5)
                    maxValue: 8
                    minValue: 1
                    amountIncrease: () => {
                        let cur = Config.get("notifications.maxVisiblePopups", 5);
                        if (cur < 8)
                            Config.updateKey("notifications.maxVisiblePopups", cur + 1);

                    }
                    amountDecrease: () => {
                        let cur = Config.get("notifications.maxVisiblePopups", 5);
                        if (cur > 1)
                            Config.updateKey("notifications.maxVisiblePopups", cur - 1);

                    }
                    isFloat: false
                    withIcon: true
                    iconCode: "filter_none"
                }

                GenericNumberOption {
                    message: "Popup Timeout (seconds)"
                    value: Math.round(Config.get("notifications.timeout", 6000) / 1000)
                    maxValue: 30
                    minValue: 3
                    amountIncrease: () => {
                        let cur = Config.get("notifications.timeout", 6000);
                        if (cur < 30000)
                            Config.updateKey("notifications.timeout", cur + 1000);

                    }
                    amountDecrease: () => {
                        let cur = Config.get("notifications.timeout", 6000);
                        if (cur > 3000)
                            Config.updateKey("notifications.timeout", cur - 1000);

                    }
                    isFloat: false
                    withIcon: true
                    iconCode: "timer"
                }

                GenericToggleOption {
                    message: "Compact Notification Cards"
                    option: Config.get("notifications.compactMode", false)
                    toRun: () => {
                        let val = !Config.get("notifications.compactMode", false);
                        Config.updateKey("notifications.compactMode", val);
                        return val;
                    }
                    withIcon: true
                    iconCode: "density_medium"
                }

                GenericToggleOption {
                    message: "Show Timeout Progress Bar"
                    option: Config.get("notifications.showTimeoutBar", true)
                    toRun: () => {
                        let val = !Config.get("notifications.showTimeoutBar", true);
                        Config.updateKey("notifications.showTimeoutBar", val);
                        return val;
                    }
                    withIcon: true
                    iconCode: "hourglass_bottom"
                }

                GenericToggleOption {
                    message: "Privacy Mode (Hide Content)"
                    option: Config.get("notifications.privacyMode", false)
                    toRun: () => {
                        let val = !Config.get("notifications.privacyMode", false);
                        Config.updateKey("notifications.privacyMode", val);
                        return val;
                    }
                    withIcon: true
                    iconCode: "visibility_off"
                }

                GenericToggleOption {
                    message: "Play Notification Sound"
                    option: Config.get("notifications.soundEnabled", true)
                    toRun: () => {
                        let val = !Config.get("notifications.soundEnabled", true);
                        Config.updateKey("notifications.soundEnabled", val);
                        return val;
                    }
                    withIcon: true
                    iconCode: "volume_up"
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
                        id: testBtn

                        property bool hovered: false

                        variant: "focus"
                        Layout.preferredWidth: 220
                        Layout.preferredHeight: 40
                        radius: Config.get("borderRadius", 20) - 8
                        color: hovered ? Colours.palette.primary : Qt.alpha(Colours.palette.primary, 0.85)

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: Styling.spacing.lg

                            Text {
                                text: "send"
                                font.family: Config.settings.iconFont
                                font.pixelSize: Styling.fontSize.title
                                color: Colours.palette.on_primary
                            }

                            Text {
                                text: "Send Test Notification"
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
                            onEntered: testBtn.hovered = true
                            onExited: testBtn.hovered = false
                            onClicked: Notifications.sendTestNotification()
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
