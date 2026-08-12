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

    property var availableScreens: {
        let list = [];
        if (Quickshell.screens) {
            for (let i = 0; i < Quickshell.screens.length; i++) {
                if (Quickshell.screens[i] && Quickshell.screens[i].name)
                    list.push(Quickshell.screens[i].name);

            }
        }
        return list.length > 0 ? list : ["eDP-1"];
    }
    property var availableEncoders: ["libx264", "libx265", "libvpx-vp9", "libaom-av1", "h264_vaapi", "hevc_vaapi", "h264_nvenc", "hevc_nvenc"]

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
                spacing: 10

                GenericTitle {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    Layout.preferredHeight: 20
                    Layout.topMargin: 10
                    text: "Miscellaneous"
                    iconCode: "flare"
                }

                GenericSeperator {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.topMargin: 5
                    Layout.preferredWidth: pageWrapper.width
                    Layout.preferredHeight: 3
                }

                GenericToggleOption {
                    message: "Nightmode on Startup"
                    option: Config.settings.nightmodeOnStartup
                    toRun: () => {
                        let newValue = !Config.settings.nightmodeOnStartup;
                        Config.updateKey("nightmodeOnStartup", newValue);
                        return newValue;
                    }
                    withIcon: true
                    iconCode: "brightness_3"
                }

                GenericNumberOption {
                    message: "Nightmode colour temperature"
                    value: parseInt(Config.settings.nightmodeColourTemp) || 5500
                    maxValue: 10000
                    minValue: 1000
                    amountIncrease: () => {
                        let current = parseInt(Config.settings.nightmodeColourTemp) || 5500;
                        if (current < 10000) {
                            let nextVal = String(current + 500);
                            Config.updateKey("nightmodeColourTemp", nextVal);
                        }
                    }
                    amountDecrease: () => {
                        let current = parseInt(Config.settings.nightmodeColourTemp) || 5500;
                        if (current > 1000) {
                            let nextVal = String(current - 500);
                            Config.updateKey("nightmodeColourTemp", nextVal);
                        }
                    }
                    isFloat: false
                    withIcon: true
                    iconCode: "device_thermostat"
                }

                GenericNumberOption {
                    message: "Eye protection notification interval (minutes)"
                    value: Config.settings.minutesBetweenHealthNotif !== undefined ? Config.settings.minutesBetweenHealthNotif : 30
                    maxValue: 180
                    minValue: 5
                    amountIncrease: () => {
                        let cur = Config.settings.minutesBetweenHealthNotif !== undefined ? Config.settings.minutesBetweenHealthNotif : 30;
                        if (cur < 180)
                            Config.updateKey("minutesBetweenHealthNotif", cur + 5);

                    }
                    amountDecrease: () => {
                        let cur = Config.settings.minutesBetweenHealthNotif !== undefined ? Config.settings.minutesBetweenHealthNotif : 30;
                        if (cur > 5)
                            Config.updateKey("minutesBetweenHealthNotif", cur - 5);

                    }
                    isFloat: false
                    withIcon: true
                    iconCode: "visibility"
                }

                GenericTextOption {
                    message: "Weather Location (City)"
                    textValue: Config.settings.weatherLocation
                    toRun: (text) => {
                        Config.updateKey("weatherLocation", text);
                        return text;
                    }
                    withIcon: true
                    iconCode: "distance"
                }

                GenericTextOption {
                    message: "GitHub Username"
                    textValue: Config.settings.misc.githubUsername || ""
                    toRun: (text) => {
                        Config.updateKey("misc.githubUsername", text);
                        return text;
                    }
                    withIcon: true
                    iconCode: "code"
                }

                GenericTitle {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    Layout.preferredHeight: 25
                    Layout.topMargin: 25
                    text: "Screen Recorder"
                    iconCode: "screen_record"
                }

                GenericSeperator {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.topMargin: 5
                    Layout.bottomMargin: 5
                    Layout.preferredWidth: pageWrapper.width
                    Layout.preferredHeight: 3
                }

                GenericSelectOption {
                    message: "Target Monitor / Screen"
                    options: root.availableScreens
                    currentIndex: {
                        let cur = Config.settings.recorder.screen || "eDP-1";
                        let idx = root.availableScreens.indexOf(cur);
                        return idx >= 0 ? idx : 0;
                    }
                    toRun: (index) => {
                        let selected = root.availableScreens[index];
                        Config.updateKey("recorder.screen", selected);
                    }
                    withIcon: true
                    iconCode: "monitor"
                }

                RowLayout {
                    id: folderRow

                    spacing: 12
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    Layout.preferredWidth: pageWrapper.width
                    Layout.preferredHeight: 50

                    Text {
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        text: "folder"
                        font.family: Config.settings.iconFont
                        font.pixelSize: 20
                        color: Qt.alpha(Colours.palette.on_surface, 0.75)
                    }

                    Text {
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        Layout.fillWidth: true
                        text: "Video Output Directory"
                        font.family: Config.settings.font
                        font.pixelSize: 15
                        color: Qt.alpha(Colours.palette.on_surface, 0.9)
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        spacing: 6

                        TextField {
                            id: dirInput

                            Layout.preferredWidth: 160
                            Layout.preferredHeight: 32
                            text: Config.settings.recorder.output_loc || "~/Videos"
                            placeholderText: "~/Videos"
                            color: Colours.palette.on_surface
                            font.family: Config.settings.font
                            font.pixelSize: 13
                            onTextEdited: {
                                Config.updateKey("recorder.output_loc", text);
                            }

                            background: Rectangle {
                                color: Colours.palette.surface_container
                                radius: Math.max(4, Config.settings.borderRadius - 12)
                                border.color: dirInput.activeFocus ? Colours.palette.primary : Qt.alpha(Colours.palette.outline, 0.5)
                                border.width: 1
                            }

                        }

                        Rectangle {
                            id: browseBtn

                            property bool hovered: false

                            Layout.preferredWidth: 34
                            Layout.preferredHeight: 32
                            radius: Math.max(4, Config.settings.borderRadius - 12)
                            color: hovered ? Colours.palette.surface_container_highest : Colours.palette.surface_container
                            border.color: Qt.alpha(Colours.palette.outline, 0.5)
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "folder_open"
                                font.family: Config.settings.iconFont
                                font.pixelSize: 18
                                color: Colours.palette.primary
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: browseBtn.hovered = true
                                onExited: browseBtn.hovered = false
                                onClicked: {
                                    IPCLoader.toggleSettings();
                                    Recorder.openFolderPicker();
                                }
                            }

                            Behavior on color {
                                PropertyAnimation {
                                    duration: 150
                                }

                            }

                        }

                        Rectangle {
                            id: openThunarBtn

                            property bool hovered: false

                            Layout.preferredWidth: 34
                            Layout.preferredHeight: 32
                            radius: Math.max(4, Config.settings.borderRadius - 12)
                            color: hovered ? Colours.palette.surface_container_highest : Colours.palette.surface_container
                            border.color: Qt.alpha(Colours.palette.outline, 0.5)
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "launch"
                                font.family: Config.settings.iconFont
                                font.pixelSize: 18
                                color: Colours.palette.primary
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: openThunarBtn.hovered = true
                                onExited: openThunarBtn.hovered = false
                                onClicked: {
                                    let loc = Config.settings.recorder.output_loc || "~/Videos";
                                    let path = loc.startsWith("/") ? loc : `${Quickshell.env("HOME")}/${loc.replace(/^~\//, "")}`;
                                    Quickshell.execDetached(["thunar", path]);
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

                GenericSelectOption {
                    message: "Video Encoder"
                    options: root.availableEncoders
                    currentIndex: {
                        let cur = Config.settings.recorder.encoder || "libx264";
                        let idx = root.availableEncoders.indexOf(cur);
                        return idx >= 0 ? idx : 0;
                    }
                    toRun: (index) => {
                        let selected = root.availableEncoders[index];
                        Config.updateKey("recorder.encoder", selected);
                    }
                    withIcon: true
                    iconCode: "movie"
                }

            }

        }

    }

    Process {
        id: encoderDetector

        running: true
        command: ["bash", "-c", "ffmpeg -encoders 2>/dev/null | grep -E '^ V\\.\\.\\.\\.D' | awk '{print $2}' | grep -E 'x264|x265|vpx|aom|svtav1|rav1e|h264|hevc|av1|vp8|vp9' | sort -u"]

        stdout: SplitParser {
            onRead: (data) => {
                let lines = `${data}`.trim().split("\n");
                let list = [];
                for (let i = 0; i < lines.length; i++) {
                    let e = lines[i].trim();
                    if (e.length > 0 && list.indexOf(e) === -1)
                        list.push(e);

                }
                if (list.length > 0)
                    Qt.callLater(() => {
                    root.availableEncoders = list;
                });

            }
        }

    }

}
