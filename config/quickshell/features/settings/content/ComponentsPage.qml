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
                spacing: 10

                GenericTitle {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    Layout.preferredHeight: 20
                    Layout.topMargin: 10
                    text: "Components"
                    iconCode: "build"
                }

                GenericSeperator {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.topMargin: 5
                    Layout.preferredWidth: pageWrapper.width
                    Layout.preferredHeight: 3
                }

                GenericToggleOption {
                    message: "Bar"
                    option: Config.get("componentControl.barIsEnabled", true)
                    toRun: () => {
                        let val = !Config.get("componentControl.barIsEnabled", true);
                        Config.updateKey("componentControl.barIsEnabled", val);
                        return val;
                    }
                    withIcon: true
                    iconCode: "bottom_navigation"
                }

                GenericToggleOption {
                    message: "Dashboard"
                    option: Config.get("componentControl.dashboardIsEnabled", true)
                    toRun: () => {
                        let val = !Config.get("componentControl.dashboardIsEnabled", true);
                        Config.updateKey("componentControl.dashboardIsEnabled", val);
                        return val;
                    }
                    withIcon: true
                    iconCode: "devices_other"
                }

                GenericToggleOption {
                    message: "Notification Server"
                    option: Config.get("componentControl.notifsIsEnabled", true)
                    toRun: () => {
                        let val = !Config.get("componentControl.notifsIsEnabled", true);
                        Config.updateKey("componentControl.notifsIsEnabled", val);
                        return val;
                    }
                    withIcon: true
                    iconCode: "notifications_active"
                }

                GenericToggleOption {
                    message: "Desktop"
                    option: Config.get("componentControl.desktopIsEnabled", true)
                    toRun: () => {
                        let val = !Config.get("componentControl.desktopIsEnabled", true);
                        Config.updateKey("componentControl.desktopIsEnabled", val);
                        return val;
                    }
                    withIcon: true
                    iconCode: "shelf_auto_hide"
                }

                GenericToggleOption {
                    message: "Lockscreen"
                    option: Config.get("componentControl.lockscreenIsEnabled", true)
                    toRun: () => {
                        let val = !Config.get("componentControl.lockscreenIsEnabled", true);
                        Config.updateKey("componentControl.lockscreenIsEnabled", val);
                        return val;
                    }
                    withIcon: true
                    iconCode: "lock_person"
                }

            }

        }

    }

}
