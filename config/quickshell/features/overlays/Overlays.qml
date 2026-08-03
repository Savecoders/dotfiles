import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.core
import qs.services

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: overlaysWindow

            property var modelData

            screen: modelData
            aboveWindows: true
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Overlay
            visible: true

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            // Volume overlay
            Rectangle {
                id: volumeOverlay

                property int volumePercent: 50
                property int lastVolume: -1
                property bool lastMuted: false
                property bool mutedInitialized: false

                function show() {
                    if (fadeOut.running)
                        fadeOut.stop();

                    fadeIn.start();
                    hideTimer.restart();
                }

                width: 250
                height: 50
                color: Colours.palette.surface_container
                radius: Math.max(4, Config.settings.borderRadius - 4)
                opacity: 0
                visible: false
                anchors.top: parent.top
                anchors.topMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter

                Timer {
                    id: hideTimer

                    interval: 2000
                    onTriggered: {
                        fadeOut.start();
                    }
                }

                SequentialAnimation {
                    id: fadeIn

                    PropertyAction {
                        target: volumeOverlay
                        property: "visible"
                        value: true
                    }

                    NumberAnimation {
                        target: volumeOverlay
                        property: "opacity"
                        to: 1
                        duration: 100
                    }

                }

                SequentialAnimation {
                    id: fadeOut

                    NumberAnimation {
                        target: volumeOverlay
                        property: "opacity"
                        to: 0
                        duration: 300
                    }

                    PropertyAction {
                        target: volumeOverlay
                        property: "visible"
                        value: false
                    }

                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8

                    Text {
                        text: Audio.muted ? "volume_off" : (volumeOverlay.volumePercent > 50 ? "volume_up" : (volumeOverlay.volumePercent > 0 ? "volume_down" : "volume_mute"))
                        color: Colours.palette.on_surface
                        font.family: Config.settings.iconFont
                        font.pixelSize: 20
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 6
                        color: Colours.palette.surface_container_high
                        radius: 3

                        Rectangle {
                            width: parent.width * (volumeOverlay.volumePercent / 100)
                            height: parent.height
                            color: Colours.palette.primary
                            radius: 3

                            Behavior on width {
                                PropertyAnimation {
                                    duration: 80
                                    easing.type: Easing.InSine
                                }

                            }

                        }

                    }

                    Text {
                        text: Audio.muted ? "Muted" : volumeOverlay.volumePercent + "%"
                        color: Colours.palette.on_surface
                        font.family: Config.settings.font
                        font.pixelSize: 12
                    }

                }

                Behavior on opacity {
                    PropertyAnimation {
                        duration: 150
                        easing.type: Easing.InSine
                    }

                }

            }

            // Brightness overlay
            Rectangle {
                id: brightnessOverlay

                property int brightnessPercent: 50
                property int lastBrightnessPercent: -1

                function show() {
                    if (bfadeOut.running)
                        bfadeOut.stop();

                    bfadeIn.start();
                    bhideTimer.restart();
                }

                width: 250
                height: 50
                color: Colours.palette.surface_container
                radius: Math.max(4, Config.settings.borderRadius - 4)
                opacity: 0
                visible: false
                anchors.top: volumeOverlay.bottom
                anchors.topMargin: 8
                anchors.horizontalCenter: parent.horizontalCenter

                Timer {
                    id: bhideTimer

                    interval: 2000
                    onTriggered: bfadeOut.start()
                }

                SequentialAnimation {
                    id: bfadeIn

                    PropertyAction {
                        target: brightnessOverlay
                        property: "visible"
                        value: true
                    }

                    NumberAnimation {
                        target: brightnessOverlay
                        property: "opacity"
                        to: 1
                        duration: 100
                    }

                }

                SequentialAnimation {
                    id: bfadeOut

                    NumberAnimation {
                        target: brightnessOverlay
                        property: "opacity"
                        to: 0
                        duration: 300
                    }

                    PropertyAction {
                        target: brightnessOverlay
                        property: "visible"
                        value: false
                    }

                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8

                    Text {
                        text: "brightness_medium"
                        color: Colours.palette.on_surface
                        font.family: Config.settings.iconFont
                        font.pixelSize: 20
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 6
                        color: Colours.palette.surface_container_high
                        radius: 3

                        Rectangle {
                            width: parent.width * (brightnessOverlay.brightnessPercent / 100)
                            height: parent.height
                            color: Colours.palette.primary
                            radius: 3

                            Behavior on width {
                                PropertyAnimation {
                                    duration: 80
                                    easing.type: Easing.InSine
                                }

                            }

                        }

                    }

                    Text {
                        text: brightnessOverlay.brightnessPercent + "%"
                        color: Colours.palette.on_surface
                        font.family: Config.settings.font
                        font.pixelSize: 12
                    }

                }

                Behavior on opacity {
                    PropertyAnimation {
                        duration: 150
                        easing.type: Easing.InSine
                    }

                }

            }

            Connections {
                function onVolumeChanged() {
                    volumeOverlay.volumePercent = Math.round(Audio.volume * 100);
                    if (volumeOverlay.lastVolume !== -1 && volumeOverlay.lastVolume !== volumeOverlay.volumePercent)
                        volumeOverlay.show();

                    volumeOverlay.lastVolume = volumeOverlay.volumePercent;
                }

                function onMutedChanged() {
                    if (volumeOverlay.mutedInitialized)
                        volumeOverlay.show();
                    else
                        volumeOverlay.mutedInitialized = true;
                }

                target: Audio
            }

            Connections {
                function onBrightnessPercentChanged() {
                    brightnessOverlay.brightnessPercent = Brightness.brightnessPercent;
                    if (brightnessOverlay.lastBrightnessPercent !== -1 && brightnessOverlay.lastBrightnessPercent !== brightnessOverlay.brightnessPercent)
                        brightnessOverlay.show();

                    brightnessOverlay.lastBrightnessPercent = brightnessOverlay.brightnessPercent;
                }

                target: Brightness
            }

            mask: Region {
            }

        }

    }

}
