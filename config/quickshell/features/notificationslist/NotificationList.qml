import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Widgets
import qs.core
import qs.features.common
import qs.services

Scope {
    signal finished()

    Variants {
        model: Globals.targetScreens

        PanelWindow {
            id: root

            property var modelData
            readonly property string barPos: Config.barPosition
            readonly property real barMargin: Config.settings.bar.margin ?? 8
            readonly property real barThickness: 40
            readonly property real barOffset: barThickness + (barMargin * 2) + 12
            readonly property real defaultMargin: 20
            readonly property string notifPos: Config.settings.notifications.position ?? "top-right"
            readonly property bool isTop: notifPos.startsWith("top")
            readonly property bool isLeft: notifPos.endsWith("left")
            readonly property bool isCenter: notifPos.endsWith("center")
            property int maxPopups: (Config.settings.notifications && Config.settings.notifications.maxVisiblePopups) ? Config.settings.notifications.maxVisiblePopups : 4
            property int notificationCount: Notifications.popupList.length

            screen: modelData
            aboveWindows: true
            exclusionMode: ExclusionMode.Ignore
            implicitHeight: 800 + root.barOffset
            implicitWidth: 450 + root.barOffset
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
                anchors.left: root.isLeft ? parent.left : (root.isCenter ? undefined : parent.left)
                anchors.right: (!root.isLeft && !root.isCenter) ? parent.right : undefined
                anchors.horizontalCenter: root.isCenter ? parent.horizontalCenter : undefined
                anchors.topMargin: (root.barPos === "top" && root.isTop) ? root.barOffset : (root.isTop ? root.defaultMargin : 0)
                anchors.bottomMargin: (root.barPos === "bottom" && !root.isTop) ? root.barOffset : (!root.isTop ? root.defaultMargin : 0)
                anchors.leftMargin: (root.barPos === "left" && root.isLeft) ? root.barOffset : (root.isLeft ? root.defaultMargin : 0)
                anchors.rightMargin: (root.barPos === "right" && (!root.isLeft && !root.isCenter)) ? root.barOffset : ((!root.isLeft && !root.isCenter) ? root.defaultMargin : 0)
                spacing: Styling.spacing.xxl

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
