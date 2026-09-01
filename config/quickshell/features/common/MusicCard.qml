import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.core
import qs.features.common.media
import qs.services

ClippingWrapperRectangle {
    id: root

    property int cardHeight: 64
    property real cardRadius: Config.get("borderRadius", 4)
    property color cardColor: Qt.rgba(0, 0, 0, 0.5)
    property color borderColor: Qt.rgba(1, 1, 1, 0.15)
    readonly property bool isCompact: cardHeight <= 70
    readonly property bool hasPlayer: Media.activePlayer != null

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
            visible: root.hasPlayer && Media.stableArtUrl !== ""
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
        StyledRect {
            anchors.fill: parent
            color: Qt.alpha(Colours.palette.surface, 0.4)
            radius: root.radius
            useDefaultRadius: false
            border.width: 0
        }

        // Main Media Card Row Layout
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: Styling.spacing.xl

            // Circular Album Art
            MediaArt {
                artSize: Math.max(36, root.cardHeight - 20)
                artRadius: Styling.radius.full
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            // Title, Artist and Timeline Info
            ColumnLayout {
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                Layout.fillWidth: true
                spacing: Styling.spacing.xs

                Text {
                    visible: !root.hasPlayer
                    font.pixelSize: root.isCompact ? Styling.fontSize.body : Styling.fontSize.bodyLarge
                    font.family: Config.settings.font ?? "SF Pro Display"
                    font.weight: Font.DemiBold
                    color: Colours.palette.on_surface_variant
                    text: "No media playing"
                }

                Text {
                    visible: root.hasPlayer
                    font.pixelSize: root.isCompact ? Styling.fontSize.body : Styling.fontSize.bodyLarge
                    font.family: Config.settings.font ?? "SF Pro Display"
                    font.weight: Font.Bold
                    color: Colours.palette.on_surface
                    text: Media.stableTitle || "Untitled"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    visible: root.hasPlayer
                    font.pixelSize: root.isCompact ? Styling.fontSize.sm : Styling.fontSize.label
                    font.family: Config.settings.font ?? "SF Pro Display"
                    color: Colours.palette.on_surface_variant
                    text: Media.stableArtist || "Unknown Artist"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                MediaTimeline {
                    visible: root.hasPlayer && hasValidLength
                    Layout.fillWidth: true
                    Layout.topMargin: 2
                    showTimestamps: true
                }

            }

            // Media Controls
            MediaControls {
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                isCompact: root.isCompact
                ctrlRadius: Math.max(2, root.cardRadius - 2)
                playRadius: Math.max(2, root.cardRadius - 2)
                showPreviousNext: true
            }

        }

    }

}
