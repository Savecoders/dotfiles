import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.core
import qs.features.common
import qs.services

Item {
    id: root

    property bool isVertical: true
    property var bottomLayout: null
    property int workspaceCount: 12
    readonly property int count: Workspaces.hyprWorkspaces ? Workspaces.hyprWorkspaces.length : workspaceCount
    // Single formula, evaluated once and reused for both orientations
    // instead of being duplicated between width: and height:.
    readonly property real crossAxisLength: metrics.thickness * count + metrics.slotSpacing * (count - 1) + metrics.outerPadding

    width: isVertical ? metrics.thickness : crossAxisLength
    height: isVertical ? crossAxisLength : metrics.thickness
    anchors.top: parent.top
    anchors.topMargin: {
        if (isVertical) {
            if (Config.settings.bar.workspacesCenterAligned) {
                let rightLen = (bottomLayout && bottomLayout.implicitHeight > 0) ? bottomLayout.implicitHeight : metrics.fallbackOppositeLength;
                let availableGap = Math.max(0, parent.height - metrics.thickness - rightLen - metrics.centeringOffset);
                return metrics.thickness + (availableGap / 2) - (height / 2);
            } else {
                return metrics.edgeMargin;
            }
        } else {
            return (parent.height / 2) - (height / 2);
        }
    }
    anchors.left: parent.left
    anchors.leftMargin: {
        if (!isVertical) {
            if (Config.settings.bar.workspacesCenterAligned) {
                let rightLen = (bottomLayout && bottomLayout.implicitWidth > 0) ? bottomLayout.implicitWidth : metrics.fallbackOppositeLength;
                let availableGap = Math.max(0, parent.width - metrics.thickness - rightLen - metrics.centeringOffset);
                return metrics.thickness + (availableGap / 2) - (width / 2);
            } else {
                return metrics.edgeMargin;
            }
        } else {
            return (parent.width / 2) - (width / 2);
        }
    }

    QtObject {
        id: metrics

        readonly property int thickness: 40 // bar thickness / collapsed slot size
        readonly property int slotSpacing: Styling.spacing.sm
        readonly property int outerPadding: Styling.spacing.lg // padding subtracted from preferredWidth/Height
        readonly property int edgeMargin: 48 // non-centered anchor margin
        readonly property int centeringOffset: Styling.spacing.xxxl // extra gap subtracted when centering
        readonly property int fallbackOppositeLength: 180
        readonly property int hoverSlotSize: 48
        readonly property int activeSlotSize: 40
        readonly property int restSlotSize: 32
        readonly property real occupiedTextAlpha: 0.9
    }

    GridLayout {
        anchors.fill: parent
        columnSpacing: metrics.slotSpacing
        rowSpacing: metrics.slotSpacing
        columns: isVertical ? 1 : root.count
        rows: isVertical ? root.count : 1

        Repeater {
            model: Workspaces.hyprWorkspaces

            StyledRect {
                id: wsItem

                property bool hovered: false
                property bool isActive: modelData.id === (Workspaces.activeWorkspace ? Workspaces.activeWorkspace.id : undefined)
                property bool hasWindows: modelData.windows > 0

                // list counts as "outermost". Merged into one function.
                function edgeRadius(isOutermost) {
                    if (hovered || isActive)
                        return Config.settings.borderRadius;

                    if (isOutermost)
                        return Config.settings.borderRadius + 4;

                    return Config.settings.borderRadius / 2;
                }

                variant: isActive ? "focus" : "internalbg"
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.preferredWidth: isVertical ? root.width - 16 : (hovered ? metrics.hoverSlotSize : (isActive ? metrics.hoverSlotSize : metrics.activeSlotSize))
                Layout.preferredHeight: isVertical ? (hovered ? metrics.activeSlotSize : (isActive ? metrics.activeSlotSize : metrics.restSlotSize)) : root.height - 16
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
                topLeftRadius: edgeRadius(index === 0)
                topRightRadius: edgeRadius(index === 0)
                bottomLeftRadius: edgeRadius(index + 1 === Workspaces.hyprWorkspaces.length)
                bottomRightRadius: edgeRadius(index + 1 === Workspaces.hyprWorkspaces.length)

                // active workspace indicator
                Text {
                    anchors.centerIn: parent
                    text: hasWindows && !isActive ? "" : "󰮯"
                    color: {
                        if (hasWindows && !isActive)
                            return Qt.alpha(Colours.palette.on_surface, metrics.occupiedTextAlpha);
                        else if (isActive)
                            return Colours.palette.on_primary;
                        else
                            return Colours.palette.outline;
                    }
                    font.family: Config.settings.font
                    font.pixelSize: hasWindows && !isActive ? Styling.fontSize.label : Styling.fontSize.lg

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
                    onEntered: wsItem.hovered = true
                    onExited: wsItem.hovered = false
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
