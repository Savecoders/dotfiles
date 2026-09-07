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

    property string currentPowerTab: "ac"
    readonly property var timeoutOptions: ["Disabled", "1 min", "2 min", "3 min", "5 min", "10 min", "15 min", "30 min", "1 hour", "2 hours"]
    readonly property var timeoutSeconds: [0, 60, 120, 180, 300, 600, 900, 1800, 3600, 7200]

    function getTimeoutIndex(sec) {
        if (sec === undefined || sec === null)
            return 0;

        let idx = timeoutSeconds.indexOf(sec);
        if (idx >= 0)
            return idx;

        let best = 0;
        let minDiff = 999999;
        for (let i = 0; i < timeoutSeconds.length; i++) {
            let diff = Math.abs(timeoutSeconds[i] - sec);
            if (diff < minDiff) {
                minDiff = diff;
                best = i;
            }
        }
        return best;
    }

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

                // SECTION 1: LOCKSCREEN
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
                    option: Config.get("lockscreen.blurBackground", true)
                    toRun: () => {
                        let val = !Config.get("lockscreen.blurBackground", true);
                        Config.updateKey("lockscreen.blurBackground", val);
                        return val;
                    }
                    withIcon: true
                    iconCode: "blur_on"
                }

                GenericToggleOption {
                    message: "Show Clock Header"
                    option: Config.get("lockscreen.showClock", true)
                    toRun: () => {
                        let val = !Config.get("lockscreen.showClock", true);
                        Config.updateKey("lockscreen.showClock", val);
                        return val;
                    }
                    withIcon: true
                    iconCode: "schedule"
                }

                GenericToggleOption {
                    message: "Show Date Subtitle"
                    option: Config.get("lockscreen.showDate", true)
                    toRun: () => {
                        let val = !Config.get("lockscreen.showDate", true);
                        Config.updateKey("lockscreen.showDate", val);
                        return val;
                    }
                    withIcon: true
                    iconCode: "calendar_today"
                }

                GenericToggleOption {
                    message: "Show Media Player Pill"
                    option: Config.get("lockscreen.showMedia", true)
                    toRun: () => {
                        let val = !Config.get("lockscreen.showMedia", true);
                        Config.updateKey("lockscreen.showMedia", val);
                        return val;
                    }
                    withIcon: true
                    iconCode: "graphic_eq"
                }

                GenericToggleOption {
                    message: "Show System Status Pill"
                    option: Config.get("lockscreen.showSystemPill", true)
                    toRun: () => {
                        let val = !Config.get("lockscreen.showSystemPill", true);
                        Config.updateKey("lockscreen.showSystemPill", val);
                        return val;
                    }
                    withIcon: true
                    iconCode: "info"
                }

                GenericToggleOption {
                    message: "Show Power Button"
                    option: Config.get("lockscreen.showPowerBtn", true)
                    toRun: () => {
                        let val = !Config.get("lockscreen.showPowerBtn", true);
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
                        radius: Config.get("borderRadius", 20) - 8
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

                // SECTION 2: IDLE & POWER MANAGEMENT
                GenericTitle {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    Layout.preferredHeight: 20
                    Layout.topMargin: 20
                    text: "Idle & Power Management"
                    iconCode: "energy_savings_leaf"
                }

                GenericSeperator {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.topMargin: 5
                    Layout.preferredWidth: pageWrapper.width
                    Layout.preferredHeight: 3
                }

                GenericToggleOption {
                    message: "Enable Idle Detection"
                    option: Config.get("idle.enabled", true)
                    toRun: () => {
                        let val = !Config.get("idle.enabled", true);
                        Config.updateKey("idle.enabled", val);
                        return val;
                    }
                    withIcon: true
                    iconCode: "bedtime"
                }

                GenericToggleOption {
                    message: "Keep Awake (Inhibit Sleep & Screensaver)"
                    option: Idle.keepAwake
                    toRun: () => {
                        Idle.toggleKeepAwake();
                        return Idle.keepAwake;
                    }
                    withIcon: true
                    iconCode: "coffee"
                }

                GenericToggleOption {
                    message: "Lock Screen Before Suspend"
                    option: Config.get("idle.lockBeforeSuspend", true)
                    toRun: () => {
                        let val = !Config.get("idle.lockBeforeSuspend", true);
                        Config.updateKey("idle.lockBeforeSuspend", val);
                        return val;
                    }
                    withIcon: true
                    iconCode: "lock_clock"
                }

                GenericToggleOption {
                    message: "Dim Screen Before Locking"
                    option: Config.get("idle.fadeDimEnabled", true)
                    toRun: () => {
                        let val = !Config.get("idle.fadeDimEnabled", true);
                        Config.updateKey("idle.fadeDimEnabled", val);
                        return val;
                    }
                    withIcon: true
                    iconCode: "brightness_medium"
                }

                GenericSeperator {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.topMargin: 5
                    Layout.preferredWidth: pageWrapper.width
                    Layout.preferredHeight: 1
                }

                // Power Mode Tabs (AC Power vs Battery)
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    spacing: Styling.spacing.md

                    // AC Power Tab Button
                    StyledRect {
                        id: acTabBtn

                        variant: "internalbg"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        radius: Config.get("borderRadius", 20) - 8
                        color: root.currentPowerTab === "ac" ? Colours.palette.primary : (acMouse.containsMouse ? Colours.palette.surface_container_high : Colours.palette.surface_container)
                        border.color: root.currentPowerTab === "ac" ? Colours.palette.primary : Colours.palette.outline_variant
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: Styling.spacing.md

                            Text {
                                text: "power"
                                font.family: Config.settings.iconFont
                                font.pixelSize: Styling.fontSize.title
                                color: root.currentPowerTab === "ac" ? Colours.palette.on_primary : Colours.palette.on_surface
                            }

                            Text {
                                text: "On AC Power"
                                font.family: Config.settings.font
                                font.pixelSize: Styling.fontSize.body
                                font.weight: root.currentPowerTab === "ac" ? 600 : 400
                                color: root.currentPowerTab === "ac" ? Colours.palette.on_primary : Colours.palette.on_surface
                            }

                        }

                        MouseArea {
                            id: acMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.currentPowerTab = "ac"
                        }

                        Behavior on color {
                            PropertyAnimation {
                                duration: 150
                                easing.type: Easing.OutQuad
                            }

                        }

                    }

                    // Battery Tab Button
                    StyledRect {
                        id: batTabBtn

                        variant: "internalbg"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        radius: Config.get("borderRadius", 20) - 8
                        color: root.currentPowerTab === "battery" ? Colours.palette.primary : (batMouse.containsMouse ? Colours.palette.surface_container_high : Colours.palette.surface_container)
                        border.color: root.currentPowerTab === "battery" ? Colours.palette.primary : Colours.palette.outline_variant
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: Styling.spacing.md

                            Text {
                                text: "battery_android_full"
                                font.family: Config.settings.iconFont
                                font.pixelSize: Styling.fontSize.title
                                color: root.currentPowerTab === "battery" ? Colours.palette.on_primary : Colours.palette.on_surface
                            }

                            Text {
                                text: "On Battery"
                                font.family: Config.settings.font
                                font.pixelSize: Styling.fontSize.body
                                font.weight: root.currentPowerTab === "battery" ? 600 : 400
                                color: root.currentPowerTab === "battery" ? Colours.palette.on_primary : Colours.palette.on_surface
                            }

                        }

                        MouseArea {
                            id: batMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.currentPowerTab = "battery"
                        }

                        Behavior on color {
                            PropertyAnimation {
                                duration: 150
                                easing.type: Easing.OutQuad
                            }

                        }

                    }

                }

                // Timeouts for selected power mode
                GenericSelectOption {
                    message: "Screen Dim Timeout"
                    iconCode: "brightness_low"
                    withIcon: true
                    options: root.timeoutOptions
                    currentIndex: root.currentPowerTab === "ac" ? root.getTimeoutIndex(Config.get("idle.ac.dimTimeout", 120)) : root.getTimeoutIndex(Config.get("idle.battery.dimTimeout", 60))
                    toRun: (index) => {
                        let sec = root.timeoutSeconds[index];
                        if (root.currentPowerTab === "ac")
                            Config.updateKey("idle.ac.dimTimeout", sec);
                        else
                            Config.updateKey("idle.battery.dimTimeout", sec);
                        return index;
                    }
                }

                GenericSelectOption {
                    message: "Screen Lock Timeout"
                    iconCode: "lock"
                    withIcon: true
                    options: root.timeoutOptions
                    currentIndex: root.currentPowerTab === "ac" ? root.getTimeoutIndex(Config.get("idle.ac.lockTimeout", 300)) : root.getTimeoutIndex(Config.get("idle.battery.lockTimeout", 180))
                    toRun: (index) => {
                        let sec = root.timeoutSeconds[index];
                        if (root.currentPowerTab === "ac")
                            Config.updateKey("idle.ac.lockTimeout", sec);
                        else
                            Config.updateKey("idle.battery.lockTimeout", sec);
                        return index;
                    }
                }

                GenericSelectOption {
                    message: "Turn Off Displays (DPMS)"
                    iconCode: "desktop_access_disabled"
                    withIcon: true
                    options: root.timeoutOptions
                    currentIndex: root.currentPowerTab === "ac" ? root.getTimeoutIndex(Config.get("idle.ac.dpmsTimeout", 360)) : root.getTimeoutIndex(Config.get("idle.battery.dpmsTimeout", 240))
                    toRun: (index) => {
                        let sec = root.timeoutSeconds[index];
                        if (root.currentPowerTab === "ac")
                            Config.updateKey("idle.ac.dpmsTimeout", sec);
                        else
                            Config.updateKey("idle.battery.dpmsTimeout", sec);
                        return index;
                    }
                }

                GenericSelectOption {
                    message: "System Suspend Timeout"
                    iconCode: "bedtime"
                    withIcon: true
                    options: root.timeoutOptions
                    currentIndex: root.currentPowerTab === "ac" ? root.getTimeoutIndex(Config.get("idle.ac.suspendTimeout", 1800)) : root.getTimeoutIndex(Config.get("idle.battery.suspendTimeout", 600))
                    toRun: (index) => {
                        let sec = root.timeoutSeconds[index];
                        if (root.currentPowerTab === "ac")
                            Config.updateKey("idle.ac.suspendTimeout", sec);
                        else
                            Config.updateKey("idle.battery.suspendTimeout", sec);
                        return index;
                    }
                }

                Item {
                    Layout.preferredHeight: 30
                }

            }

        }

    }

}
