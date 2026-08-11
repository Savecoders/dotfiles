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
import qs.features.dashboard
import qs.services

Loader {
    id: root

    required property bool isDashboardOpen
    property int dashWidth: 515
    property int dashHeight: 800
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
    onIsDashboardOpenChanged: {
        if (root.isDashboardOpen == true) {
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
                id: dashboardWindow

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

                Item {
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

                    // Dashboard Main Rounded Panel
                    Rectangle {
                        id: mainPanel

                        anchors.fill: parent
                        color: Colours.palette.surface
                        radius: Config.settings.borderRadius
                        border.color: Qt.alpha(Colours.palette.outline, 0.15)
                        border.width: 1
                        clip: true

                        MouseArea {
                            property int startX

                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            onPressed: (event) => {
                                startX = event.x;
                            }
                            onPositionChanged: (event) => {
                                let difference = startX - event.x;
                                if ((root._isLeft && difference > 30) || (!root._isLeft && difference < -30))
                                    IPCLoader.isDashboardOpen = false;

                            }
                        }

                        ScrollView {
                            anchors.fill: parent
                            clip: true
                            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                            ScrollBar.vertical.policy: ScrollBar.AsNeeded

                            ColumnLayout {
                                id: contentColumn

                                width: mainPanel.width
                                spacing: 16

                                GithubContribCalendar {
                                    Layout.fillWidth: true
                                    Layout.leftMargin: 20
                                    Layout.rightMargin: 20
                                    Layout.topMargin: 20
                                }

                                Toggles {
                                }

                                MusicCard {
                                    cardHeight: 88
                                    Layout.fillWidth: true
                                    Layout.leftMargin: 20
                                    Layout.rightMargin: 20
                                }

                                Sliders {
                                }

                                SystemStats {
                                }

                                Bottom {
                                    Layout.fillWidth: true
                                    Layout.leftMargin: 20
                                    Layout.rightMargin: 20
                                    Layout.bottomMargin: 20
                                }

                            }

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
