import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.core
import qs.features
import qs.features.common
import qs.features.desktop

Scope {
    id: root

    signal finished()

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: desktopWindow

            property var modelData
            readonly property bool roundingShown: Config.get("desktop.desktopRoundingShown", true)
            readonly property real targetGap: roundingShown ? Styling.desktopGap : 0
            readonly property real targetRadius: roundingShown ? (Config.settings.borderRadius ?? 16) : 0

            property real animatedGap: targetGap
            property real animatedRadius: targetRadius

            screen: modelData
            color: "transparent"
            visible: true
            aboveWindows: false
            WlrLayershell.layer: WlrLayer.Bottom
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            mask: Region {
            }

            Behavior on animatedGap {
                NumberAnimation {
                    duration: Config.settings.animationSpeed ?? 200
                    easing.type: Easing.OutQuad
                }
            }

            Behavior on animatedRadius {
                NumberAnimation {
                    duration: Config.settings.animationSpeed ?? 200
                    easing.type: Easing.OutQuad
                }
            }

            // Outer decorative border frame with inner rounded cutout (OddEvenFill)
            Shape {
                id: borderShape

                anchors.fill: parent
                visible: desktopWindow.animatedGap > 0
                asynchronous: true

                ShapePath {
                    fillColor: Colours.palette.surface
                    strokeColor: "transparent"
                    strokeWidth: 0
                    fillRule: ShapePath.OddEvenFill

                    Behavior on fillColor {
                        ColorAnimation {
                            duration: Config.settings.animationSpeed ?? 200
                        }
                    }

                    // Outer screen boundary
                    PathRectangle {
                        x: 0
                        y: 0
                        width: desktopWindow.width
                        height: desktopWindow.height
                    }

                    // Inner cutout displaying wallpaper underneath
                    PathRectangle {
                        x: desktopWindow.animatedGap
                        y: desktopWindow.animatedGap
                        width: Math.max(0, desktopWindow.width - (desktopWindow.animatedGap * 2))
                        height: Math.max(0, desktopWindow.height - (desktopWindow.animatedGap * 2))
                        radius: desktopWindow.animatedRadius
                    }
                }
            }

            Rectangle {
                id: dimmingOverlay

                x: desktopWindow.animatedGap
                y: desktopWindow.animatedGap
                width: Math.max(0, desktopWindow.width - (desktopWindow.animatedGap * 2))
                height: Math.max(0, desktopWindow.height - (desktopWindow.animatedGap * 2))
                radius: desktopWindow.animatedRadius
                color: "black"
                opacity: Config.get("desktop.dimDesktopWallpaper", false) ? 0.15 : 0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Config.settings.animationSpeed ?? 200
                        easing.type: Easing.OutQuad
                    }
                }
            }
        }
    }
}
