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

            StyledRect {
                id: floatingTooltip

                readonly property bool isScreenMatch: !Tooltip.targetScreen || Tooltip.targetScreen === overlaysWindow.screen
                readonly property bool shouldShow: Tooltip.visible && Tooltip.text !== "" && isScreenMatch

                variant: "popup"
                visible: opacity > 0
                opacity: shouldShow ? 1 : 0
                scale: shouldShow ? 1 : 0.94
                implicitWidth: tooltipText.implicitWidth + (Styling.spacing.lg * 2)
                implicitHeight: tooltipText.implicitHeight + (Styling.spacing.md * 2)
                width: implicitWidth
                height: implicitHeight
                x: Math.max(Styling.spacing.lg, Math.min(parent.width - width - Styling.spacing.lg, Tooltip.globalX + (Tooltip.targetWidth / 2) - (width / 2)))
                y: {
                    if (Tooltip.preferredPos === "top" || (Tooltip.preferredPos === "auto" && Tooltip.globalY > parent.height / 2))
                        return Math.max(Styling.spacing.lg, Tooltip.globalY - height - Styling.spacing.sm);
                    else
                        return Math.min(parent.height - height - Styling.spacing.lg, Tooltip.globalY + Tooltip.targetHeight + Styling.spacing.sm);
                }

                Text {
                    id: tooltipText

                    anchors.centerIn: parent
                    text: Tooltip.text
                    font.family: Config.settings.font ?? "SF Pro Display"
                    font.pixelSize: Styling.fontSize.sm
                    font.weight: Font.Medium
                    color: Colours.palette.on_surface
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Config.settings.animationSpeed ?? 150
                        easing.type: Easing.OutQuad
                    }

                }

                Behavior on scale {
                    NumberAnimation {
                        duration: Config.settings.animationSpeed ?? 150
                        easing.type: Easing.OutQuad
                    }

                }

            }

            mask: Region {
            }

        }

    }

}
