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

                GenericToggleOption {
                    message: "Show a rounded border"
                    option: Config.settings.desktop.desktopRoundingShown
                    toRun: () => {
                        Config.settings.desktop.desktopRoundingShown = !Config.settings.desktop.desktopRoundingShown;
                        Config.updateKey("desktop.desktopRoundingShown", Config.settings.desktop.desktopRoundingShown);
                        return Config.settings.desktop.desktopRoundingShown;
                    }
                    withIcon: true
                    iconCode: "capture"
                }

                GenericToggleOption {
                    message: "Dim the wallpaper"
                    option: Config.settings.desktop.dimDesktopWallpaper
                    toRun: () => {
                        Config.settings.desktop.dimDesktopWallpaper = !Config.settings.desktop.dimDesktopWallpaper;
                        Config.updateKey("desktop.dimDesktopWallpaper", Config.settings.desktop.dimDesktopWallpaper);
                        return Config.settings.desktop.dimDesktopWallpaper;
                    }
                    withIcon: true
                    iconCode: "brightness_6"
                }

            }

        }

    }

}
