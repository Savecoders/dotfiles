import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.core
import qs.features

Loader {
    id: root

    required property bool isOpen
    property real anchorX: 0
    property real anchorY: 0
    property real anchorWidth: 0
    property real anchorHeight: 0
    property real cardWidth: 320
    property real contentMargin: 16
    property Component cardContent: null
    readonly property real screenMargin: 20
    readonly property real fallbackScreenWidth: 1920
    readonly property real fallbackScreenHeight: 1080
    readonly property real edgeFallbackOffset: 48
    readonly property real barMargin: (Config.settings && Config.settings.bar && Config.settings.bar.margin !== undefined) ? Config.settings.bar.margin : 8
    readonly property real barClearance: 12 + barMargin
    readonly property string barPos: Config.barPosition

    signal dismissed()

    active: false
    onIsOpenChanged: {
        if (root.isOpen) {
            deactivateTimer.stop();
            root.active = true;
        } else {
            deactivateTimer.restart();
        }
    }

    Timer {
        id: deactivateTimer

        interval: (Config.settings && Config.settings.animationSpeed !== undefined ? Config.settings.animationSpeed : 150) + 50
        repeat: false
        onTriggered: {
            if (!root.isOpen)
                root.active = false;

        }
    }

    sourceComponent: Scope {
        Variants {
            model: Globals.targetScreens

            PanelWindow {
                id: popupWin

                property var modelData
                readonly property real screenWidth: popupWin.screen ? popupWin.screen.width : root.fallbackScreenWidth
                readonly property real screenHeight: popupWin.screen ? popupWin.screen.height : root.fallbackScreenHeight

                screen: modelData
                aboveWindows: true
                exclusionMode: ExclusionMode.Ignore
                color: "transparent"
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: root.isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
                focusable: root.isOpen
                visible: root.isOpen

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                // Full-screen backdrop to dismiss on click outside and handle Escape
                MouseArea {
                    anchors.fill: parent
                    focus: root.isOpen
                    Keys.onEscapePressed: {
                        root.dismissed();
                    }
                    onClicked: {
                        root.dismissed();
                    }
                }

                // Popup card positioned dynamically next to anchor widget
                StyledRect {
                    id: card

                    variant: "popup"
                    useDefaultRadius: true
                    width: root.cardWidth
                    height: innerContentLoader.item ? (innerContentLoader.item.implicitHeight + (root.contentMargin * 2)) : 200
                    color: Colours.palette.surface
                    border.color: Colours.palette.outline_variant
                    border.width: 1
                    opacity: root.isOpen ? 1 : 0
                    scale: root.isOpen ? 1 : 0.94
                    // Dynamic coordinate calculation based on bar position with 20px screen and bar margins
                    x: {
                        if (root.barPos === "left") {
                            let leftX = root.anchorWidth > 0 ? (root.anchorX + root.anchorWidth + root.barClearance) : (root.edgeFallbackOffset + root.screenMargin);
                            return Math.max(root.screenMargin, Math.min(popupWin.screenWidth - width - root.screenMargin, leftX));
                        } else if (root.barPos === "right") {
                            let rightX = root.anchorWidth > 0 ? (root.anchorX - width - root.barClearance) : (popupWin.screenWidth - width - root.edgeFallbackOffset);
                            return Math.max(root.screenMargin, Math.min(popupWin.screenWidth - width - root.screenMargin, rightX));
                        } else {
                            // Top or Bottom: Center horizontally on anchor widget
                            let targetCenter = root.anchorWidth > 0 ? (root.anchorX + (root.anchorWidth / 2)) : (popupWin.screenWidth / 2);
                            return Math.max(root.screenMargin, Math.min(popupWin.screenWidth - width - root.screenMargin, targetCenter - (width / 2)));
                        }
                    }
                    y: {
                        if (root.barPos === "bottom") {
                            let topY = root.anchorHeight > 0 ? (root.anchorY - height - root.barClearance) : (popupWin.screenHeight - height - root.edgeFallbackOffset);
                            return Math.max(root.screenMargin, Math.min(popupWin.screenHeight - height - root.screenMargin, topY));
                        } else if (root.barPos === "top") {
                            let bottomY = root.anchorHeight > 0 ? (root.anchorY + root.anchorHeight + root.barClearance) : (root.edgeFallbackOffset + root.screenMargin);
                            return Math.max(root.screenMargin, Math.min(popupWin.screenHeight - height - root.screenMargin, bottomY));
                        } else {
                            // Left or Right: Align vertically with anchor widget
                            let targetCenter = root.anchorHeight > 0 ? (root.anchorY + (root.anchorHeight / 2)) : (popupWin.screenHeight / 2);
                            return Math.max(root.screenMargin, Math.min(popupWin.screenHeight - height - root.screenMargin, targetCenter - (height / 2)));
                        }
                    }

                    // Click-through prevention: absorbs clicks inside card surface
                    MouseArea {
                        anchors.fill: parent
                        onClicked: (mouse) => {
                            mouse.accepted = true;
                        }
                    }

                    Loader {
                        id: innerContentLoader

                        anchors.fill: parent
                        anchors.margins: root.contentMargin
                        sourceComponent: root.cardContent
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Config.settings && Config.settings.animationSpeed !== undefined ? Config.settings.animationSpeed : 150
                            easing.type: Easing.OutQuad
                        }

                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: Config.settings && Config.settings.animationSpeed !== undefined ? Config.settings.animationSpeed : 150
                            easing.type: Easing.OutQuad
                        }

                    }

                }

            }

        }

    }

}
