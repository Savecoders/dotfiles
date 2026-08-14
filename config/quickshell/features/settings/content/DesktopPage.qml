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
                spacing: 10

                GenericTitle {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    Layout.preferredHeight: 20
                    Layout.topMargin: 10
                    text: "Desktop"
                    iconCode: "shelf_auto_hide"
                }

                GenericSeperator {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.topMargin: 5
                    Layout.preferredWidth: pageWrapper.width
                    Layout.preferredHeight: 3
                }

                GenericSelectOption {
                    id: targetScreenSelect

                    message: "Display components on"
                    withIcon: true
                    iconCode: "monitor"
                    options: {
                        let opts = ["All Displays"];
                        if (Quickshell.screens) {
                            for (let i = 0; i < Quickshell.screens.length; i++) {
                                if (Quickshell.screens[i] && Quickshell.screens[i].name)
                                    opts.push(Quickshell.screens[i].name);

                            }
                        }
                        return opts;
                    }
                    currentIndex: {
                        let cur = (Config.settings && Config.settings.desktop && Config.settings.desktop.targetScreen) ? Config.settings.desktop.targetScreen : "all";
                        if (cur === "all" || cur === "")
                            return 0;

                        let idx = options.indexOf(cur);
                        return idx !== -1 ? idx : 0;
                    }
                    toRun: (index) => {
                        if (index === 0)
                            Config.updateKey("desktop.targetScreen", "all");
                        else if (index < options.length)
                            Config.updateKey("desktop.targetScreen", options[index]);
                    }
                }

                GenericToggleOption {
                    message: "Show a rounded border"
                    option: Config.settings.desktop.desktopRoundingShown
                    toRun: () => {
                        let val = !Config.settings.desktop.desktopRoundingShown;
                        Config.updateKey("desktop.desktopRoundingShown", val);
                        return val;
                    }
                    withIcon: true
                    iconCode: "capture"
                }

                GenericToggleOption {
                    message: "Dim the wallpaper"
                    option: Config.settings.desktop.dimDesktopWallpaper
                    toRun: () => {
                        let val = !Config.settings.desktop.dimDesktopWallpaper;
                        Config.updateKey("desktop.dimDesktopWallpaper", val);
                        return val;
                    }
                    withIcon: true
                    iconCode: "brightness_6"
                }

            }

        }

    }

}
