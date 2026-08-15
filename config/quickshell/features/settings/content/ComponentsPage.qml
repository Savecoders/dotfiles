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
                    option: Config.settings.componentControl.barIsEnabled
                    toRun: () => {
                        let val = !Config.settings.componentControl.barIsEnabled;
                        Config.updateKey("componentControl.barIsEnabled", val);
                        return val;
                    }
                    withIcon: true
                    iconCode: "bottom_navigation"
                }

                GenericToggleOption {
                    message: "Dashboard"
                    option: Config.settings.componentControl.dashboardIsEnabled
                    toRun: () => {
                        let val = !Config.settings.componentControl.dashboardIsEnabled;
                        Config.updateKey("componentControl.dashboardIsEnabled", val);
                        return val;
                    }
                    withIcon: true
                    iconCode: "devices_other"
                }

                GenericToggleOption {
                    message: "Notification Server"
                    option: Config.settings.componentControl.notifsIsEnabled
                    toRun: () => {
                        let val = !Config.settings.componentControl.notifsIsEnabled;
                        Config.updateKey("componentControl.notifsIsEnabled", val);
                        return val;
                    }
                    withIcon: true
                    iconCode: "notifications_active"
                }

                GenericToggleOption {
                    message: "Desktop"
                    option: Config.settings.componentControl.desktopIsEnabled
                    toRun: () => {
                        let val = !Config.settings.componentControl.desktopIsEnabled;
                        Config.updateKey("componentControl.desktopIsEnabled", val);
                        return val;
                    }
                    withIcon: true
                    iconCode: "shelf_auto_hide"
                }

                GenericToggleOption {
                    message: "Lockscreen"
                    option: Config.settings.componentControl.lockscreenIsEnabled
                    toRun: () => {
                        let val = !Config.settings.componentControl.lockscreenIsEnabled;
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
