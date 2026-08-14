import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick.Layouts
import Quickshell.Widgets
import qs.core
import qs.services
import qs.features.common

Scope {
    signal finished()

    Variants {
        model: Globals.targetScreens

        PanelWindow {
            id: root

            property var modelData
            readonly property string notifPos: (Config.settings.notifications && Config.settings.notifications.position) ? Config.settings.notifications.position : "top-right"
            readonly property bool isTop: notifPos.startsWith("top")
            readonly property bool isLeft: notifPos.endsWith("left")
            readonly property bool isCenter: notifPos.endsWith("center")
            property int maxPopups: (Config.settings.notifications && Config.settings.notifications.maxVisiblePopups) ? Config.settings.notifications.maxVisiblePopups : 4
            property int notificationCount: Notifications.popupList.length

            screen: modelData
            aboveWindows: true
            exclusionMode: ExclusionMode.Ignore
            implicitHeight: 800
            implicitWidth: 450
            color: "transparent"
            visible: true

            anchors {
                top: isTop
                bottom: !isTop
                left: isLeft
                right: !isLeft && !isCenter
            }

            ListView {
                id: maskId

                verticalLayoutDirection: root.isTop ? ListView.TopToBottom : ListView.BottomToTop
                implicitHeight: Math.min(maskId.contentHeight, 760)
                implicitWidth: 400
                anchors.top: root.isTop ? parent.top : undefined
                anchors.bottom: !root.isTop ? parent.bottom : undefined
                anchors.topMargin: root.isTop ? 20 : 0
                anchors.bottomMargin: !root.isTop ? 20 : 0
                anchors.left: root.isLeft ? parent.left : (root.isCenter ? undefined : parent.left)
                anchors.right: (!root.isLeft && !root.isCenter) ? parent.right : undefined
                anchors.horizontalCenter: root.isCenter ? parent.horizontalCenter : undefined
                anchors.leftMargin: root.isLeft ? 20 : 0
                anchors.rightMargin: (!root.isLeft && !root.isCenter) ? 20 : 0
                spacing: 12

                model: ScriptModel {
                    values: (Notifications.popupList || []).slice().reverse().slice(0, root.maxPopups)
                }

                Behavior on implicitWidth {
                    NumberAnimation {
                        duration: 200
                        easing.bezierCurve: Anim.standard
                    }

                }

                Behavior on implicitHeight {
                    NumberAnimation {
                        duration: 200
                        easing.bezierCurve: Anim.standard
                    }

                }

                add: Transition {
                    NumberAnimation {
                        duration: 500
                        easing.bezierCurve: Anim.standard
                        from: root.isTop ? -300 : (maskId.height + 300)
                        property: "y"
                    }

                }

                addDisplaced: Transition {
                    NumberAnimation {
                        duration: 500
                        easing.bezierCurve: Anim.standard
                        properties: "x,y"
                    }

                }

                delegate: SingleNotification {
                    required property Notifications.Notif modelData

                    popup: true
                }

                remove: Transition {
                    NumberAnimation {
                        duration: 500
                        easing.bezierCurve: Anim.standard
                        property: "y"
                        to: root.isTop ? -300 : (maskId.height + 300)
                    }

                }

                removeDisplaced: Transition {
                    NumberAnimation {
                        duration: 500
                        easing.bezierCurve: Anim.standard
                        properties: "x,y"
                    }

                }

            }

            mask: Region {
                item: maskId.contentItem
            }

        }

    }

}
