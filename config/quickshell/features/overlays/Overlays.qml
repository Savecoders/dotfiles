import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.core
import qs.features.common
import qs.services

Scope {
    id: root

    Variants {
        model: Globals.targetScreens

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
            OSDOverlay {
                id: volumeOverlay

                property int lastVolume: -1
                property bool mutedInitialized: false

                percent: Math.round((Audio.volume ?? 0) * 100)
                iconName: Audio.muted ? "volume_off" : (percent > 50 ? "volume_up" : (percent > 0 ? "volume_down" : "volume_mute"))
                labelText: Audio.muted ? "Muted" : percent + "%"
                anchors.centerIn: parent
            }

            // Brightness overlay
            OSDOverlay {
                id: brightnessOverlay

                property int lastBrightness: -1

                percent: Brightness.brightnessPercent ?? 50
                iconName: "brightness_medium"
                labelText: percent + "%"
                anchors.centerIn: parent
            }

            Connections {
                function onVolumeChanged() {
                    let cur = Math.round((Audio.volume ?? 0) * 100);
                    if (volumeOverlay.lastVolume !== -1 && volumeOverlay.lastVolume !== cur)
                        volumeOverlay.show();

                    volumeOverlay.lastVolume = cur;
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
                    let cur = Brightness.brightnessPercent ?? 50;
                    if (brightnessOverlay.lastBrightness !== -1 && brightnessOverlay.lastBrightness !== cur)
                        brightnessOverlay.show();

                    brightnessOverlay.lastBrightness = cur;
                }

                target: Brightness
            }

            mask: Region {
            }

        }

    }

}
