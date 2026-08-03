import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.core
import qs.features.common
import qs.services

Rectangle {
    id: root

    property bool isVertical: true
    property var bottomLayout: null
    property int workspaceCount: 12

    width: isVertical ? 40 : 40 * (Workspaces.hyprWorkspaces ? Workspaces.hyprWorkspaces.length : 1) + 4 * ((Workspaces.hyprWorkspaces ? Workspaces.hyprWorkspaces.length : 1) - 1) + 8
    height: isVertical ? 40 * (Workspaces.hyprWorkspaces ? Workspaces.hyprWorkspaces.length : 1) + 4 * ((Workspaces.hyprWorkspaces ? Workspaces.hyprWorkspaces.length : 1) - 1) + 8 : 40
    color: "transparent"
    anchors.top: parent.top
    anchors.topMargin: {
        if (isVertical) {
            if (Config.settings.bar.workspacesCenterAligned) {
                let rightLen = (bottomLayout && bottomLayout.implicitHeight > 0) ? bottomLayout.implicitHeight : 180;
                let availableGap = Math.max(0, parent.height - 40 - rightLen - 16);
                return 40 + (availableGap / 2) - (height / 2);
            } else {
                return 48;
            }
        } else {
            return (parent.height / 2) - (height / 2);
        }
    }
    anchors.left: parent.left
    anchors.leftMargin: {
        if (!isVertical) {
            if (Config.settings.bar.workspacesCenterAligned) {
                let rightLen = (bottomLayout && bottomLayout.implicitWidth > 0) ? bottomLayout.implicitWidth : 180;
                let availableGap = Math.max(0, parent.width - 40 - rightLen - 16);
                return 40 + (availableGap / 2) - (width / 2);
            } else {
                return 48;
            }
        } else {
            return (parent.width / 2) - (width / 2);
        }
    }

    GridLayout {
        anchors.fill: parent
        columnSpacing: 4
        rowSpacing: 4
        columns: isVertical ? 1 : 20
        rows: isVertical ? 20 : 1

        Repeater {
            model: Workspaces.hyprWorkspaces

            Rectangle {
                property bool hovered: false
                property bool isActive: modelData.id === (Workspaces.activeWorkspace ? Workspaces.activeWorkspace.id : undefined)
                property bool hasWindows: modelData.windows > 0

                function getTopRadius() {
                    if (hovered || isActive)
                        return Config.settings.borderRadius;

                    if (index == 0)
                        return Config.settings.borderRadius + 4;

                    return Config.settings.borderRadius / 2;
                }

                function getBottomRadius() {
                    if (hovered || isActive)
                        return Config.settings.borderRadius;

                    if (index + 1 == Workspaces.hyprWorkspaces.length)
                        return Config.settings.borderRadius + 4;

                    return Config.settings.borderRadius / 2;
                }

                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.preferredWidth: isVertical ? root.width - 16 : (hovered ? 48 : (isActive ? 48 : 40))
                Layout.preferredHeight: isVertical ? (hovered ? 40 : (isActive ? 40 : 32)) : root.height - 16
                Layout.rightMargin: 0
                color: {
                    if (isActive)
                        return Colours.palette.primary;
                    else if (hovered)
                        return Colours.palette.primary_container;
                    else if (hasWindows)
                        return Colours.palette.on_primary;
                    else
                        return "transparent";
                }
                topLeftRadius: getTopRadius()
                topRightRadius: getTopRadius()
                bottomLeftRadius: getBottomRadius()
                bottomRightRadius: getBottomRadius()

                Text {
                    anchors.centerIn: parent
                    text: hasWindows && !isActive ? "" : "󰮯"
                    color: {
                        if (hasWindows && !isActive)
                            return Qt.alpha(Colours.palette.on_surface, 0.9);
                        else if (isActive)
                            return Colours.palette.on_primary;
                        else
                            return Colours.palette.outline;
                    }
                    font.family: Config.settings.font
                    font.pixelSize: hasWindows && !isActive ? 12 : 16

                    Behavior on color {
                        PropertyAnimation {
                            duration: 200
                            easing.type: Easing.InSine
                        }

                    }

                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: parent.hovered = true
                    onExited: parent.hovered = false
                    onClicked: Hyprland.changeWorkspace(modelData.id)
                }

                Behavior on topLeftRadius {
                    PropertyAnimation {
                        duration: Config.settings.animationSpeed
                        easing.type: Easing.InSine
                    }

                }

                Behavior on topRightRadius {
                    PropertyAnimation {
                        duration: Config.settings.animationSpeed
                        easing.type: Easing.InSine
                    }

                }

                Behavior on bottomLeftRadius {
                    PropertyAnimation {
                        duration: Config.settings.animationSpeed
                        easing.type: Easing.InSine
                    }

                }

                Behavior on bottomRightRadius {
                    PropertyAnimation {
                        duration: Config.settings.animationSpeed
                        easing.type: Easing.InSine
                    }

                }

                Behavior on Layout.preferredHeight {
                    PropertyAnimation {
                        duration: Config.settings.animationSpeed
                        easing.type: Easing.InSine
                    }

                }

                Behavior on Layout.preferredWidth {
                    PropertyAnimation {
                        duration: Config.settings.animationSpeed
                        easing.type: Easing.InSine
                    }

                }

            }

        }

    }

    Behavior on anchors.topMargin {
        PropertyAnimation {
            duration: Config.settings.animationSpeed
            easing.type: Easing.InSine
        }

    }

    Behavior on anchors.leftMargin {
        PropertyAnimation {
            duration: Config.settings.animationSpeed
            easing.type: Easing.InSine
        }

    }

}
