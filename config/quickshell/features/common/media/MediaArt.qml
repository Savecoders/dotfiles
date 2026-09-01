import QtQuick
import Quickshell.Widgets
import qs.core
import qs.services

ClippingWrapperRectangle {
    id: root

    property real artSize: 36
    property real artRadius: Styling.radius.full
    property real fallbackIconSize: Math.round(artSize * 0.45)
    property string artUrl: Media.stableArtUrl
    property bool hasPlayer: Media.activePlayer != null

    radius: artRadius
    implicitWidth: artSize
    implicitHeight: artSize
    width: implicitWidth
    height: implicitHeight
    color: Qt.alpha(Colours.palette.surface_container_highest, 0.8)

    Item {
        anchors.fill: parent

        Image {
            id: albumCover

            anchors.fill: parent
            sourceSize: Qt.size(root.artSize, root.artSize)
            visible: root.hasPlayer && root.artUrl !== "" && (status === Image.Ready || status === Image.Loading)
            source: root.artUrl
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }

        Text {
            anchors.centerIn: parent
            visible: !root.hasPlayer || root.artUrl === "" || albumCover.status === Image.Error || albumCover.status === Image.Null
            color: Colours.palette.outline
            text: "music_note"
            font.family: Config.settings.iconFont
            font.pixelSize: root.fallbackIconSize
        }

    }

}
