import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls
import Quickshell.Widgets
import Quickshell.Services.Mpris
import qs.services
import qs.core
import qs.features.common
import qs.features

ClippingWrapperRectangle {
    id: root

    property int fHeight: 88

    Layout.fillWidth: true
    Layout.leftMargin: 20
    Layout.rightMargin: 20
    Layout.preferredHeight: fHeight
    radius: Math.max(4, Config.settings.borderRadius - 8)
    color: Qt.alpha(Colours.palette.surface, 0.85)
    border.color: Qt.alpha(Colours.palette.outline, 0.25)
    border.width: 1

    Item {
        anchors.fill: parent

        Image {
            id: bgArt

            anchors.fill: parent
            visible: Media.activePlayer != null && Media.stableArtUrl !== ""
            source: Media.stableArtUrl
            fillMode: Image.PreserveAspectCrop
            sourceSize: Qt.size(200, 200)
            asynchronous: true
            opacity: 0.45
        }

        MultiEffect {
            anchors.fill: bgArt
            source: bgArt
            visible: bgArt.visible
            blurEnabled: true
            blurMax: 32
            blur: 0.95
            contrast: 0.15
            saturation: 0.25
        }

        // Dark Overlay
        Rectangle {
            anchors.fill: parent
            color: Qt.alpha(Colours.palette.surface_container, 0.55)
            radius: root.radius
        }

        // 2. Main Media Card Row Layout
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            spacing: 12

            // Circular Album Art
            ClippingWrapperRectangle {
                id: art

                radius: 1000
                Layout.preferredWidth: 50
                Layout.preferredHeight: 50
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                color: Colours.palette.surface_container

                Item {
                    anchors.fill: parent

                    Image {
                        id: albumCover

                        anchors.fill: parent
                        visible: Media.activePlayer != null && Media.stableArtUrl !== "" && (status === Image.Ready || status === Image.Loading)
                        source: Media.stableArtUrl
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: Media.activePlayer == null || Media.stableArtUrl === "" || albumCover.status === Image.Error || albumCover.status === Image.Null
                        color: Colours.palette.outline
                        text: "music_note"
                        font.family: Config.settings.iconFont
                        font.pixelSize: 22
                    }

                }

            }

            // Title and Artist Info
            ColumnLayout {
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                Layout.fillWidth: true
                spacing: 2

                Text {
                    visible: Media.activePlayer == null
                    font.pixelSize: 14
                    font.family: Config.settings.font
                    font.weight: 600
                    color: Qt.alpha(Colours.palette.on_surface, 0.7)
                    text: "No media playing"
                }

                Text {
                    visible: Media.activePlayer != null
                    font.pixelSize: 14
                    font.family: Config.settings.font
                    font.weight: 700
                    color: Colours.palette.on_surface
                    text: Media.stableTitle || "Untitled"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    visible: Media.activePlayer != null
                    font.pixelSize: 12
                    font.family: Config.settings.font
                    color: Qt.alpha(Colours.palette.on_surface, 0.7)
                    text: Media.stableArtist || "Unknown Artist"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

            }

            // Controls
            RowLayout {
                visible: Media.activePlayer != null
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                spacing: 4

                PlayerControl {
                    iconName: "skip_previous"
                    toRun: () => {
                        if (Media.activePlayer && Media.activePlayer.canGoPrevious)
                            Media.activePlayer.previous();

                    }
                    width: 32
                    height: 32
                    bgColour: Qt.alpha(Colours.palette.surface, 0.4)
                    colour: Colours.palette.on_surface
                    bgColourHovered: Colours.palette.surface_container_highest
                    colourHovered: Colours.palette.on_surface
                }

                PlayerControl {
                    iconName: Media.isPlaying ? "pause" : "play_arrow"
                    toRun: function() {
                        if (Media.activePlayer)
                            Media.activePlayer.togglePlaying();

                    }
                    width: 36
                    height: 36
                    bgColour: Colours.palette.primary
                    colour: Colours.palette.on_primary
                    bgColourHovered: Qt.alpha(Colours.palette.primary, 0.85)
                    colourHovered: Colours.palette.on_primary
                }

                PlayerControl {
                    iconName: "skip_next"
                    toRun: () => {
                        if (Media.activePlayer && Media.activePlayer.canGoNext)
                            Media.activePlayer.next();

                    }
                    width: 32
                    height: 32
                    bgColour: Qt.alpha(Colours.palette.surface, 0.4)
                    colour: Colours.palette.on_surface
                    bgColourHovered: Colours.palette.surface_container_highest
                    colourHovered: Colours.palette.on_surface
                }

            }

        }

    }

}
