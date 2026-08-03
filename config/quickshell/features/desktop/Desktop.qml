import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
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

            screen: modelData
            color: Colours.palette.surface
            visible: true
            aboveWindows: false
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            Connections {
                function onWallpaperToSetChanged() {
                    realWallpaper.opacity = 0;
                }

                target: Config.settings
            }

            ClippingWrapperRectangle {
                id: wallpaperUnderlay

                anchors.top: parent.top
                anchors.left: parent.left
                width: Config.settings.desktop.desktopRoundingShown ? parent.width - 8 : parent.width
                height: Config.settings.desktop.desktopRoundingShown ? parent.height - 8 : parent.height
                anchors.topMargin: 4
                anchors.leftMargin: 4
                radius: Config.settings.desktop.desktopRoundingShown ? Config.settings.borderRadius : 0
                color: "transparent"
                opacity: 1

                Image {
                    id: backgroundUnderlay

                    source: Config.settings.wallpaperToSet
                    fillMode: Image.PreserveAspectCrop
                    sourceSize: Qt.size(desktopWindow.width, desktopWindow.height)
                    asynchronous: true
                    cache: true

                    MultiEffect {
                        id: darkenEffectUnderlay

                        source: backgroundUnderlay
                        anchors.fill: parent
                        opacity: Config.settings.desktop.dimDesktopWallpaper ? 1 : 0
                        brightness: -0.1

                        Behavior on opacity {
                            PropertyAnimation {
                                duration: Config.settings.animationSpeed
                                easing.type: Easing.InSine
                            }

                        }

                    }

                }

                Behavior on radius {
                    PropertyAnimation {
                        duration: Config.settings.animationSpeed
                        easing.type: Easing.InSine
                    }

                }

                Behavior on height {
                    PropertyAnimation {
                        duration: Config.settings.animationSpeed
                        easing.type: Easing.InSine
                    }

                }

                Behavior on width {
                    PropertyAnimation {
                        duration: Config.settings.animationSpeed
                        easing.type: Easing.InSine
                    }

                }

            }

            ClippingWrapperRectangle {
                id: realWallpaper

                anchors.top: parent.top
                anchors.left: parent.left
                width: Config.settings.desktop.desktopRoundingShown ? parent.width - 8 : parent.width
                height: Config.settings.desktop.desktopRoundingShown ? parent.height - 8 : parent.height
                anchors.topMargin: 4
                anchors.leftMargin: 4
                radius: Config.settings.desktop.desktopRoundingShown ? Config.settings.borderRadius : 0
                color: "transparent"
                opacity: 1
                onOpacityChanged: {
                    if (opacity === 0) {
                        Config.settings.currentWallpaper = Config.settings.wallpaperToSet;
                        realWallpaper.opacity = 1;
                    }
                }

                Image {
                    id: background

                    source: Config.settings.currentWallpaper
                    fillMode: Image.PreserveAspectCrop
                    sourceSize: Qt.size(desktopWindow.width, desktopWindow.height)
                    asynchronous: true
                    cache: true

                    MultiEffect {
                        id: darkenEffect

                        source: background
                        anchors.fill: background
                        opacity: Config.settings.desktop.dimDesktopWallpaper ? 1 : 0
                        brightness: -0.1

                        Behavior on opacity {
                            PropertyAnimation {
                                duration: Config.settings.animationSpeed
                                easing.type: Easing.InSine
                            }

                        }

                    }

                }

                Behavior on radius {
                    PropertyAnimation {
                        duration: Config.settings.animationSpeed
                        easing.type: Easing.InSine
                    }

                }

                Behavior on height {
                    PropertyAnimation {
                        duration: Config.settings.animationSpeed
                        easing.type: Easing.InSine
                    }

                }

                Behavior on width {
                    PropertyAnimation {
                        duration: Config.settings.animationSpeed
                        easing.type: Easing.InSine
                    }

                }

                Behavior on opacity {
                    PropertyAnimation {
                        duration: Config.settings.animationSpeed + 400
                        easing.type: Easing.InSine
                    }

                }

            }

            ColorQuantizer {
                id: colorQuantizer

                source: Qt.resolvedUrl(Config.settings.currentWallpaper)
                depth: 0
                rescaleSize: 128
            }

        }

    }

}
