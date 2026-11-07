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
    // Optional screen captured by the caller (for example IPCLoader.batteryScreen).
    // It sizes the anchored popup placement and drives the fullscreen fallback.
    property var targetScreen: null
    // Optional caller item captured by IPCLoader.toggle*At. When present, the
    // popup is a modal PopupWindow anchored to a transient 1x1 host, so the
    // normal path allocates no fullscreen backdrop.
    property var anchorItem: null
    // Set when the anchor dies while the popup is open; the component then
    // switches to the established fullscreen fallback instead of leaving a
    // ghost popup or silently dropping the open state.
    property bool anchorLost: false
    onAnchorItemChanged: root.anchorLost = false
    // Fallback path: callers without a live anchor keep the previous
    // Globals.targetScreens selection, including its missing-monitor fallback.
    readonly property bool hasValidTargetScreen: {
        if (!root.targetScreen)
            return false;

        const screens = Globals.targetScreens || [];
        return screens.indexOf(root.targetScreen) !== -1;
    }
    readonly property bool hasAnchorItem: !!root.anchorItem && !root.anchorLost && root.hasValidTargetScreen
    readonly property real popupScreenWidth: root.targetScreen ? root.targetScreen.width : root.fallbackScreenWidth
    readonly property real popupScreenHeight: root.targetScreen ? root.targetScreen.height : root.fallbackScreenHeight
    readonly property real screenMargin: 20
    readonly property real fallbackScreenWidth: 1920
    readonly property real fallbackScreenHeight: 1080
    readonly property real edgeFallbackOffset: 48
    readonly property real barMargin: Config.get("bar.margin", 8)
    readonly property real barClearance: 12 + barMargin
    readonly property string barPos: Config.barPosition

    signal dismissed()

    function cardXFor(screenWidth, width) {
        if (root.barPos === "left") {
            let leftX = root.anchorWidth > 0 ? (root.anchorX + root.anchorWidth + root.barClearance) : (root.edgeFallbackOffset + root.screenMargin);
            return Math.max(root.screenMargin, Math.min(screenWidth - width - root.screenMargin, leftX));
        } else if (root.barPos === "right") {
            let rightX = root.anchorWidth > 0 ? (root.anchorX - width - root.barClearance) : (screenWidth - width - root.edgeFallbackOffset);
            return Math.max(root.screenMargin, Math.min(screenWidth - width - root.screenMargin, rightX));
        } else {
            // Top or Bottom: Center horizontally on anchor widget
            let targetCenter = root.anchorWidth > 0 ? (root.anchorX + (root.anchorWidth / 2)) : (screenWidth / 2);
            return Math.max(root.screenMargin, Math.min(screenWidth - width - root.screenMargin, targetCenter - (width / 2)));
        }
    }

    function cardYFor(screenHeight, height) {
        if (root.barPos === "bottom") {
            let topY = root.anchorHeight > 0 ? (root.anchorY - height - root.barClearance) : (screenHeight - height - root.edgeFallbackOffset);
            return Math.max(root.screenMargin, Math.min(screenHeight - height - root.screenMargin, topY));
        } else if (root.barPos === "top") {
            let bottomY = root.anchorHeight > 0 ? (root.anchorY + root.anchorHeight + root.barClearance) : (root.edgeFallbackOffset + root.screenMargin);
            return Math.max(root.screenMargin, Math.min(screenHeight - height - root.screenMargin, bottomY));
        } else {
            // Left or Right: Align vertically with anchor widget
            let targetCenter = root.anchorHeight > 0 ? (root.anchorY + (root.anchorHeight / 2)) : (screenHeight / 2);
            return Math.max(root.screenMargin, Math.min(screenHeight - height - root.screenMargin, targetCenter - (height / 2)));
        }
    }

    active: false
    onIsOpenChanged: {
        if (root.isOpen) {
            // Each open retries the anchored path; IPC opens have already
            // cleared anchorItem, so they still select the fallback.
            root.anchorLost = false;
            deactivateTimer.stop();
            root.active = true;
        } else {
            deactivateTimer.restart();
        }
    }

    Timer {
        id: deactivateTimer

        interval: Config.get("animationSpeed", 150) + 50
        repeat: false
        onTriggered: {
            if (!root.isOpen)
                root.active = false;

        }
    }

    Component {
        id: cardComponent

        StyledRect {
            id: card

            anchors.fill: parent
            variant: "popup"
            useDefaultRadius: true
            implicitWidth: root.cardWidth
            implicitHeight: cardContentLoader.item ? (cardContentLoader.item.implicitHeight + (root.contentMargin * 2)) : 200
            color: Transparency.colorFor(variant)
            border.color: Colours.palette.outline_variant
            border.width: 1
            opacity: root.isOpen ? 1 : 0
            scale: root.isOpen ? 1 : 0.94

            // Click-through prevention: absorbs clicks inside card surface
            MouseArea {
                anchors.fill: parent
                onClicked: (mouse) => {
                    mouse.accepted = true;
                }
            }

            Loader {
                id: cardContentLoader

                anchors.fill: parent
                anchors.margins: root.contentMargin
                sourceComponent: root.cardContent
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Config.get("animationSpeed", 150)
                    easing.type: Easing.OutQuad
                }

            }

            Behavior on scale {
                NumberAnimation {
                    duration: Config.get("animationSpeed", 150)
                    easing.type: Easing.OutQuad
                }

            }

        }

    }

    sourceComponent: Scope {
        // Live caller anchor: one transient 1x1 layer host supplies the popup
        // parent surface and the anchor rectangle stays inside it. The popup
        // itself is card-sized; no fullscreen backdrop is allocated.
        Loader {
            active: root.hasAnchorItem

            sourceComponent: Component {
                PanelWindow {
                    id: anchorHost

                    screen: root.targetScreen
                    aboveWindows: true
                    exclusionMode: ExclusionMode.Ignore
                    color: "transparent"
                    WlrLayershell.layer: WlrLayer.Overlay
                    WlrLayershell.keyboardFocus: root.isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
                    focusable: root.isOpen
                    visible: root.isOpen
                    implicitWidth: 1
                    implicitHeight: 1

                    anchors {
                        top: true
                        left: true
                    }

                    margins {
                        top: Math.round(root.cardYFor(root.popupScreenHeight, popupWin.cardHeight))
                        left: Math.round(root.cardXFor(root.popupScreenWidth, root.cardWidth))
                    }

                    PopupWindow {
                        id: popupWin

                        readonly property real cardHeight: popupCardLoader.item ? popupCardLoader.item.implicitHeight : 200

                        anchor.window: anchorHost
                        anchor.rect.x: 0
                        anchor.rect.y: 0
                        implicitWidth: root.cardWidth
                        implicitHeight: popupWin.cardHeight
                        color: "transparent"
                        grabFocus: true
                        visible: root.isOpen
                        onClosed: {
                            if (popupWin.anchor.window)
                                root.dismissed();
                            else
                                root.anchorLost = true;

                        }

                        Connections {
                            target: popupWin.anchor

                            function onWindowChanged() {
                                if (!root.isOpen || popupWin.anchor.window)
                                    return ;

                                Qt.callLater(() => {
                                    if (root.isOpen && !popupWin.anchor.window)
                                        root.anchorLost = true;

                                });
                            }
                        }

                        FocusScope {
                            anchors.fill: parent
                            focus: true
                            Keys.onEscapePressed: {
                                root.dismissed();
                            }

                            Loader {
                                id: popupCardLoader

                                anchors.fill: parent
                                sourceComponent: cardComponent
                            }

                        }

                    }

                }

            }

        }

        // No live caller anchor (for example an IPC toggle before any widget
        // capture): keep the previous fullscreen backdrop presentation and its
        // cross-monitor dismissal on Globals.targetScreens.
        Loader {
            active: !root.hasAnchorItem

            sourceComponent: Component {
                Variants {
                    model: Globals.targetScreens

                    PanelWindow {
                        id: fallbackWin

                        property var modelData
                        // Callers without a valid explicit screen keep the previous
                        // presentation: the card is shown on every target screen.
                        readonly property bool isPopupScreen: !root.hasValidTargetScreen || fallbackWin.screen === root.targetScreen
                        readonly property real screenWidth: fallbackWin.screen ? fallbackWin.screen.width : root.fallbackScreenWidth
                        readonly property real screenHeight: fallbackWin.screen ? fallbackWin.screen.height : root.fallbackScreenHeight

                        screen: modelData
                        aboveWindows: true
                        exclusionMode: ExclusionMode.Ignore
                        color: "transparent"
                        WlrLayershell.layer: WlrLayer.Overlay
                        WlrLayershell.keyboardFocus: (root.isOpen && fallbackWin.isPopupScreen) ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
                        focusable: root.isOpen && fallbackWin.isPopupScreen
                        visible: root.isOpen

                        anchors {
                            top: true
                            bottom: true
                            left: true
                            right: true
                        }

                        // Full-screen backdrop on every target screen: preserves
                        // the previous outside-click dismissal from any monitor.
                        // Only the popup screen owns keyboard focus (Escape).
                        MouseArea {
                            anchors.fill: parent
                            focus: root.isOpen && fallbackWin.isPopupScreen
                            Keys.onEscapePressed: {
                                root.dismissed();
                            }
                            onClicked: {
                                root.dismissed();
                            }
                        }

                        Loader {
                            id: fallbackCardLoader

                            active: fallbackWin.isPopupScreen
                            x: root.cardXFor(fallbackWin.screenWidth, root.cardWidth)
                            y: root.cardYFor(fallbackWin.screenHeight, fallbackCardLoader.item ? fallbackCardLoader.item.implicitHeight : 200)
                            width: root.cardWidth
                            height: fallbackCardLoader.item ? fallbackCardLoader.item.implicitHeight : 200
                            sourceComponent: cardComponent
                        }

                    }

                }

            }

        }

    }

}
