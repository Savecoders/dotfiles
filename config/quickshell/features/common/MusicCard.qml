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

ClippingWrapperRectangle {
    id: root

    property int cardHeight: 64
    property real cardRadius: (Config.settings && Config.settings.borderRadius !== undefined) ? Config.settings.borderRadius : 4
    property color cardColor: Qt.rgba(0, 0, 0, 0.5)
    property color borderColor: Qt.rgba(1, 1, 1, 0.15)

    implicitHeight: cardHeight
    radius: cardRadius
    color: cardColor
    border.color: borderColor
    border.width: 1

    Item {
        anchors.fill: parent

        // Blurred Album Art Background
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
            color: Qt.rgba(0, 0, 0, 0.35)
            radius: root.radius
        }

        // Main Media Card Row Layout
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 10

            // Circular Album Art
            ClippingWrapperRectangle {
                id: art

                readonly property real artSize: Math.max(36, root.cardHeight - 22)

                radius: 1000
                Layout.preferredWidth: artSize
                Layout.preferredHeight: artSize
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                color: Qt.rgba(0, 0, 0, 0.4)

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
                        font.pixelSize: Math.round(art.artSize * 0.45)
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
                    font.pixelSize: root.cardHeight > 70 ? 14 : 13
                    font.family: Config.settings.font
                    font.weight: Font.DemiBold
                    color: Qt.rgba(1, 1, 1, 0.7)
                    text: "No media playing"
                }

                Text {
                    visible: Media.activePlayer != null
                    font.pixelSize: root.cardHeight > 70 ? 14 : 13
                    font.family: Config.settings.font
                    font.weight: Font.Bold
                    color: Qt.rgba(1, 1, 1, 0.95)
                    text: Media.stableTitle || "Untitled"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    visible: Media.activePlayer != null
                    font.pixelSize: root.cardHeight > 70 ? 12 : 11
                    font.family: Config.settings.font
                    color: Qt.rgba(1, 1, 1, 0.7)
                    text: Media.stableArtist || "Unknown Artist"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

            }

            // Media Controls
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
                    width: root.cardHeight > 70 ? 32 : 30
                    height: root.cardHeight > 70 ? 32 : 30
                    radius: Math.max(2, root.cardRadius - 2)
                    bgColour: Qt.rgba(0, 0, 0, 0.35)
                    colour: Qt.rgba(1, 1, 1, 0.9)
                    bgColourHovered: Qt.rgba(1, 1, 1, 0.2)
                    colourHovered: "#ffffff"
                }

                PlayerControl {
                    iconName: Media.isPlaying ? "pause" : "play_arrow"
                    toRun: function() {
                        if (Media.activePlayer)
                            Media.activePlayer.togglePlaying();

                    }
                    width: root.cardHeight > 70 ? 36 : 30
                    height: root.cardHeight > 70 ? 36 : 30
                    radius: Math.max(2, root.cardRadius - 2)
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
                    width: root.cardHeight > 70 ? 32 : 30
                    height: root.cardHeight > 70 ? 32 : 30
                    radius: Math.max(2, root.cardRadius - 2)
                    bgColour: Qt.rgba(0, 0, 0, 0.35)
                    colour: Qt.rgba(1, 1, 1, 0.9)
                    bgColourHovered: Qt.rgba(1, 1, 1, 0.2)
                    colourHovered: "#ffffff"
                }

            }

        }

    }

}
