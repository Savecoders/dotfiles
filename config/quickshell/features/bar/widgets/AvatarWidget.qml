import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.core
import qs.features

Item {
    id: root

    property bool isVertical: false
    property int iconSize: 24

    function resolvePfpPath(loc) {
        const location = loc || "~/.face";
        const path = location.startsWith("/") ? location : `${Quickshell.env("HOME")}/${location.replace(/^~\//, "")}`;
        return `file://${path}`;
    }

    implicitWidth: iconSize
    implicitHeight: iconSize
    width: implicitWidth
    height: implicitHeight

    IconImage {
        id: icon

        anchors.fill: parent
        opacity: Config.settings.usePfpInsteadOfLogo ? 0 : 1
        source: Qt.resolvedUrl(Quickshell.shellDir + "/assets/icon.png")

        Behavior on opacity {
            PropertyAnimation {
                duration: Config.settings.animationSpeed
                easing.type: Easing.InSine
            }

        }

    }

    ClippingWrapperRectangle {
        id: pfp

        anchors.fill: parent
        opacity: Config.settings.usePfpInsteadOfLogo ? 1 : 0
        color: "transparent"
        radius: Styling.radius.round

        Loader {
            anchors.fill: parent
            active: (Config.settings.usePfpInsteadOfLogo ?? false) && Config.get("pfpLocation", "") !== ""

            sourceComponent: IconImage {
                property bool pfpFailed: false
                property string targetSource: root.resolvePfpPath(Config.get("pfpLocation", ""))

                anchors.fill: parent
                onTargetSourceChanged: pfpFailed = false
                source: pfpFailed ? Qt.resolvedUrl(Quickshell.shellDir + "/assets/icon.png") : targetSource
                onStatusChanged: {
                    if (status === Image.Error)
                        pfpFailed = true;

                }
            }

        }

        Behavior on opacity {
            PropertyAnimation {
                duration: Config.settings.animationSpeed
                easing.type: Easing.InSine
            }

        }

    }

}
