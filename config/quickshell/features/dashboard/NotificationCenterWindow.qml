import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.core
import qs.features
import qs.features.common
import qs.features.dashboard
import qs.services

Loader {
    id: root

    required property bool isNotificationsOpen
    property int dashWidth: 515
    property int dashHeight: 960
    property int dashHoriPadding: 60
    property int dashVertPadding: 60
    readonly property string _pos: {
        const p = Config.settings.bar.position;
        return (p === "left" || p === "right") ? p : "left";
    }
    readonly property bool _isLeft: _pos === "left"
    property bool ani
    property real _targetMargin: -root.dashWidth

    active: false
    onIsNotificationsOpenChanged: {
        if (root.isNotificationsOpen == true) {
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
                id: notifyWindow

                property var modelData

                screen: modelData
                aboveWindows: true
                color: "transparent"
                implicitHeight: root.dashHeight + root.dashVertPadding
                implicitWidth: root.dashWidth + root.dashHoriPadding
                exclusionMode: ExclusionMode.Ignore
                visible: true

                anchors {
                    bottom: true
                    left: root._isLeft
                    right: !root._isLeft
                }

                ScrollView {
                    id: maskId

                    implicitHeight: 0
                    implicitWidth: root.dashWidth
                    anchors.leftMargin: root._isLeft ? root._targetMargin : undefined
                    anchors.rightMargin: !root._isLeft ? root._targetMargin : undefined
                    opacity: 0
                    anchors.bottomMargin: root.dashVertPadding
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
                            maskId.implicitHeight = root.dashHeight;
                            root._targetMargin = root.dashHoriPadding;
                            maskId.opacity = 1;
                        }
                    }

                    Timer {
                        running: !root.ani
                        repeat: false
                        interval: 1
                        onTriggered: {
                            root._targetMargin = -root.dashWidth;
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

                    Rectangle {
                        anchors.fill: parent
                        color: Colours.palette.surface
                        radius: Config.settings.borderRadius

                        NotificationLog {
                        }

                    }

                    Behavior on anchors.leftMargin {
                        enabled: root._isLeft

                        PropertyAnimation {
                            duration: 200
                            easing.type: Easing.InSine
                        }

                    }

                    Behavior on anchors.rightMargin {
                        enabled: !root._isLeft

                        PropertyAnimation {
                            duration: 200
                            easing.type: Easing.InSine
                        }

                    }

                    Behavior on implicitHeight {
                        PropertyAnimation {
                            duration: Config.settings.animationSpeed
                            easing.type: Easing.InSine
                        }

                    }

                    Behavior on opacity {
                        PropertyAnimation {
                            duration: Config.settings.animationSpeed
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
