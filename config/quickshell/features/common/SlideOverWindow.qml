import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs.core

Loader {
    id: root

    required property bool isOpen
    property Component contentComponent
    property int panelWidth: 515
    property int panelHeight: 880
    property string side: "left"
    readonly property string barPos: Config.barPosition
    readonly property bool isBarLeft: barPos === "left"
    readonly property bool isBarRight: barPos === "right"
    readonly property bool isBarTop: barPos === "top"
    readonly property bool isBarBottom: barPos === "bottom"
    readonly property bool isBarVertical: isBarLeft || isBarRight
    readonly property bool isBarHorizontal: isBarTop || isBarBottom
    readonly property real barMargin: Config.settings.bar.margin ?? 8
    readonly property real barThickness: 40
    readonly property real barClearance: barThickness + (barMargin * 2) + 8
    readonly property real sideMargin: barMargin + 8
    property bool animatedIn: false

    active: false
    onIsOpenChanged: {
        if (root.isOpen) {
            root.active = true;
            openTimer.start();
        } else {
            root.animatedIn = false;
            closeTimer.start();
        }
    }

    Timer {
        id: openTimer

        interval: 10
        repeat: false
        onTriggered: {
            root.animatedIn = true;
        }
    }

    Timer {
        id: closeTimer

        interval: (Config.settings.animationSpeed + 50) ?? 250
        repeat: false
        onTriggered: {
            if (!root.isOpen)
                root.active = false;

        }
    }

    sourceComponent: Scope {
        signal finished()

        Variants {
            model: Globals.targetScreens

            PanelWindow {
                id: slideWindow

                property var modelData

                screen: modelData
                aboveWindows: true
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                visible: true
                implicitWidth: root.isBarVertical ? (root.panelWidth + root.barClearance) : (root.panelWidth + (root.sideMargin * 2))
                implicitHeight: root.isBarVertical ? (root.panelHeight + root.sideMargin) : (root.panelHeight + root.barClearance)

                anchors {
                    top: root.isBarTop
                    bottom: !root.isBarTop
                    left: root.isBarLeft || (root.isBarHorizontal && root.side === "left")
                    right: root.isBarRight || (root.isBarHorizontal && root.side === "right")
                }

                Item {
                    id: maskId

                    implicitWidth: root.panelWidth
                    implicitHeight: root.panelHeight
                    opacity: root.animatedIn ? 1 : 0
                    clip: true
                    // Anchoring rules per bar orientation
                    anchors.top: root.isBarTop ? parent.top : undefined
                    anchors.bottom: !root.isBarTop ? parent.bottom : undefined
                    anchors.left: (root.isBarLeft || (root.isBarHorizontal && root.side === "left")) ? parent.left : undefined
                    anchors.right: (root.isBarRight || (root.isBarHorizontal && root.side === "right")) ? parent.right : undefined
                    // Margin animations per orientation
                    anchors.topMargin: root.isBarTop ? (root.animatedIn ? root.barClearance : -root.panelHeight) : 0
                    anchors.bottomMargin: root.isBarBottom ? (root.animatedIn ? root.barClearance : -root.panelHeight) : (root.isBarVertical ? root.sideMargin : 0)
                    anchors.leftMargin: root.isBarLeft ? (root.animatedIn ? root.barClearance : -root.panelWidth) : (root.isBarHorizontal && root.side === "left" ? root.sideMargin : 0)
                    anchors.rightMargin: root.isBarRight ? (root.animatedIn ? root.barClearance : -root.panelWidth) : (root.isBarHorizontal && root.side === "right" ? root.sideMargin : 0)

                    StyledRect {
                        id: mainPanel

                        variant: "popup"
                        anchors.fill: parent
                        color: Colours.palette.surface
                        radius: Config.settings.borderRadius ?? 8
                        border.color: Qt.alpha(Colours.palette.outline, 0.15)
                        border.width: 1
                        clip: true

                        Loader {
                            anchors.fill: parent
                            sourceComponent: root.contentComponent
                        }

                    }

                    Behavior on anchors.topMargin {
                        PropertyAnimation {
                            duration: Config.settings.animationSpeed ?? 200
                            easing.type: Easing.OutCubic
                        }

                    }

                    Behavior on anchors.bottomMargin {
                        PropertyAnimation {
                            duration: Config.settings.animationSpeed ?? 200
                            easing.type: Easing.OutCubic
                        }

                    }

                    Behavior on anchors.leftMargin {
                        PropertyAnimation {
                            duration: Config.settings.animationSpeed ?? 200
                            easing.type: Easing.OutCubic
                        }

                    }

                    Behavior on anchors.rightMargin {
                        PropertyAnimation {
                            duration: Config.settings.animationSpeed ?? 200
                            easing.type: Easing.OutCubic
                        }

                    }

                    Behavior on opacity {
                        PropertyAnimation {
                            duration: Config.settings.animationSpeed ?? 200
                            easing.type: Easing.InSine
                        }

                    }

                }

                mask: Region {
                    item: maskId
                }

            }

        }

    }

}
