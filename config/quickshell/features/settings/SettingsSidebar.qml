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
import qs.features.settings.sidebar
import qs.services

Item {
    id: root

    property int location: SettingsControl.settingsLocation
    property bool collapsed: false

    ColumnLayout {
        anchors.fill: parent
        spacing: Styling.spacing.sm

        // Sidebar Header with Collapse Toggle Button
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            Layout.bottomMargin: Styling.spacing.sm

            Text {
                visible: !root.collapsed
                text: "SETTINGS"
                font.family: Config.settings.font
                font.pixelSize: Styling.fontSize.sm
                font.weight: 700
                color: Qt.alpha(Colours.palette.on_surface, 0.4)
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                Layout.leftMargin: Styling.spacing.lg
            }

            Item {
                Layout.fillWidth: true
            }

            StyledRect {
                id: collapseBtn

                property bool hovered: false

                variant: "internalbg"
                useDefaultRadius: false
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                Layout.alignment: root.collapsed ? (Qt.AlignHCenter | Qt.AlignVCenter) : (Qt.AlignRight | Qt.AlignVCenter)
                radius: Styling.radius.xxl
                color: hovered ? Colours.palette.surface_container_highest : Colours.palette.surface_container

                Text {
                    anchors.centerIn: parent
                    text: root.collapsed ? "chevron_right" : "chevron_left"
                    font.family: Config.settings.iconFont
                    font.pixelSize: Styling.fontSize.headline
                    color: Colours.palette.on_surface
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: collapseBtn.hovered = true
                    onExited: collapseBtn.hovered = false
                    onClicked: root.collapsed = !root.collapsed
                }

                Behavior on color {
                    PropertyAnimation {
                        duration: 150
                    }

                }

            }

            Item {
                visible: root.collapsed
                Layout.fillWidth: true
            }

        }

        // Section 1: Appearance
        Text {
            visible: !root.collapsed
            text: "APPEARANCE"
            font.family: Config.settings.font
            font.pixelSize: Styling.fontSize.xs
            font.weight: 700
            color: Qt.alpha(Colours.palette.on_surface, 0.4)
            Layout.topMargin: Styling.spacing.sm
            Layout.leftMargin: Styling.spacing.lg
        }

        SidebarButton {
            rWidth: parent.width
            rHeight: 40
            collapsed: root.collapsed
            bigText: "Desktop"
            iconCode: "shelf_auto_hide"
            toRun: () => {
                return SettingsControl.setLocation(0);
            }
            number: 0
            selected: root.location
        }

        SidebarButton {
            rWidth: parent.width
            rHeight: 40
            collapsed: root.collapsed
            bigText: "Bar"
            iconCode: "bottom_navigation"
            toRun: () => {
                return SettingsControl.setLocation(1);
            }
            number: 1
            selected: root.location
        }

        SidebarButton {
            rWidth: parent.width
            rHeight: 40
            collapsed: root.collapsed
            bigText: "Theming"
            iconCode: "format_paint"
            toRun: () => {
                return SettingsControl.setLocation(2);
            }
            number: 2
            selected: root.location
        }

        // Section 2: System
        Text {
            visible: !root.collapsed
            text: "SYSTEM"
            font.family: Config.settings.font
            font.pixelSize: Styling.fontSize.xs
            font.weight: 700
            color: Qt.alpha(Colours.palette.on_surface, 0.4)
            Layout.topMargin: Styling.spacing.lg
            Layout.leftMargin: Styling.spacing.lg
        }

        SidebarButton {
            rWidth: parent.width
            rHeight: 40
            collapsed: root.collapsed
            bigText: "Notifications"
            iconCode: "notifications_active"
            toRun: () => {
                return SettingsControl.setLocation(3);
            }
            number: 3
            selected: root.location
        }

        SidebarButton {
            rWidth: parent.width
            rHeight: 40
            collapsed: root.collapsed
            bigText: "Lockscreen"
            iconCode: "lock"
            toRun: () => {
                return SettingsControl.setLocation(4);
            }
            number: 4
            selected: root.location
        }

        SidebarButton {
            rWidth: parent.width
            rHeight: 40
            collapsed: root.collapsed
            bigText: "Services & Extras"
            iconCode: "flare"
            toRun: () => {
                return SettingsControl.setLocation(5);
            }
            number: 5
            selected: root.location
        }

        SidebarButton {
            rWidth: parent.width
            rHeight: 40
            collapsed: root.collapsed
            bigText: "Components"
            iconCode: "build"
            toRun: () => {
                return SettingsControl.setLocation(6);
            }
            number: 6
            selected: root.location
        }

        // Section 3: Information
        Text {
            visible: !root.collapsed
            text: "INFORMATION"
            font.family: Config.settings.font
            font.pixelSize: Styling.fontSize.xs
            font.weight: 700
            color: Qt.alpha(Colours.palette.on_surface, 0.4)
            Layout.topMargin: Styling.spacing.lg
            Layout.leftMargin: Styling.spacing.lg
        }

        SidebarButton {
            rWidth: parent.width
            rHeight: 40
            collapsed: root.collapsed
            bigText: "About"
            iconCode: "info"
            toRun: () => {
                return SettingsControl.setLocation(7);
            }
            number: 7
            selected: root.location
        }

        Item {
            Layout.fillHeight: true
        }

    }

}
