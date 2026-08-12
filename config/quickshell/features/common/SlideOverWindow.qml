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
    property int panelHeight: 800
    property int horiPadding: 60
    property int vertPadding: 60
    readonly property string _pos: {
        const p = (Config.settings && Config.settings.bar && Config.settings.bar.position) ? Config.settings.bar.position : "left";
        return (p === "left" || p === "right") ? p : "left";
    }
    readonly property bool _isLeft: _pos === "left"
    property bool ani
    property real _targetMargin: -root.panelWidth

    active: false
    onIsOpenChanged: {
        if (root.isOpen === true) {
            root.active = true;
            root.ani = true;
        } else {
            root.ani = false;
        }
    }

    sourceComponent: Scope {
        signal finished()

        Variants {
            model: Quickshell.screens

            PanelWindow {
                id: slideWindow

                property var modelData

                screen: modelData
                aboveWindows: true
                color: "transparent"
                implicitHeight: root.panelHeight + root.vertPadding
                implicitWidth: root.panelWidth + root.horiPadding
                exclusionMode: ExclusionMode.Ignore
                visible: true

                anchors {
                    bottom: true
                    left: root._isLeft
                    right: !root._isLeft
                }

                Item {
                    id: maskId

                    implicitHeight: 0
                    implicitWidth: root.panelWidth
                    anchors.leftMargin: root._isLeft ? root._targetMargin : undefined
                    anchors.rightMargin: !root._isLeft ? root._targetMargin : undefined
                    opacity: 0
                    anchors.bottomMargin: root.vertPadding
                    clip: true

                    anchors {
                        bottom: parent.bottom
                        top: undefined
                        left: root._isLeft ? parent.left : undefined
                        right: !root._isLeft ? parent.right : undefined
                    }

                    Timer {
                        running: root.ani
                        repeat: false
                        interval: 1
                        onTriggered: {
                            maskId.implicitHeight = root.panelHeight;
                            root._targetMargin = root.horiPadding;
                            maskId.opacity = 1;
                        }
                    }

                    Timer {
                        running: !root.ani
                        repeat: false
                        interval: 1
                        onTriggered: {
                            root._targetMargin = -root.panelWidth;
                            maskId.implicitHeight = 0;
                            maskId.opacity = 0;
                        }
                    }

                    Timer {
                        running: !root.ani
                        repeat: false
                        interval: 250
                        onTriggered: {
                            root.active = false;
                        }
                    }

                    StyledRect {
                        id: mainPanel

                        variant: "popup"
                        anchors.fill: parent
                        color: Colours.palette.surface
                        radius: (Config.settings && Config.settings.borderRadius !== undefined) ? Config.settings.borderRadius : 8
                        border.color: Qt.alpha(Colours.palette.outline, 0.15)
                        border.width: 1
                        clip: true

                        Loader {
                            anchors.fill: parent
                            sourceComponent: root.contentComponent
                        }

                    }

                    Behavior on anchors.leftMargin {
                        PropertyAnimation {
                            duration: (Config.settings && Config.settings.animationSpeed !== undefined) ? Config.settings.animationSpeed : 200
                            easing.type: Easing.InSine
                        }

                    }

                    Behavior on anchors.rightMargin {
                        PropertyAnimation {
                            duration: (Config.settings && Config.settings.animationSpeed !== undefined) ? Config.settings.animationSpeed : 200
                            easing.type: Easing.InSine
                        }

                    }

                    Behavior on implicitHeight {
                        PropertyAnimation {
                            duration: (Config.settings && Config.settings.animationSpeed !== undefined) ? Config.settings.animationSpeed : 200
                            easing.type: Easing.InSine
                        }

                    }

                    Behavior on opacity {
                        PropertyAnimation {
                            duration: (Config.settings && Config.settings.animationSpeed !== undefined) ? Config.settings.animationSpeed : 200
                            easing.type: Easing.InSine
                        }

                    }

                }

            }

        }

    }

}
