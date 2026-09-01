import QtQuick
import QtQuick.Layouts
import qs.core
import qs.features.common
import qs.services

Item {
    id: root

    property bool showPreviousNext: true
    property bool isVertical: false
    property bool isCompact: false
    property real ctrlSize: isCompact ? 30 : 32
    property real playSize: isCompact ? 30 : 36
    property real ctrlRadius: 4
    property real playRadius: 4
    property bool hasPlayer: Media.activePlayer != null

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight
    visible: hasPlayer

    GridLayout {
        id: layout

        anchors.fill: parent
        columns: root.isVertical ? 1 : 3
        rows: root.isVertical ? 3 : 1
        columnSpacing: Styling.spacing.sm
        rowSpacing: Styling.spacing.sm

        PlayerControl {
            visible: root.showPreviousNext
            iconName: "skip_previous"
            toRun: () => {
                if (Media.activePlayer && Media.activePlayer.canGoPrevious)
                    Media.activePlayer.previous();

            }
            width: root.ctrlSize
            height: root.ctrlSize
            radius: root.ctrlRadius
            bgColour: Qt.rgba(0, 0, 0, 0.35)
            colour: Qt.rgba(1, 1, 1, 0.9)
            bgColourHovered: Qt.rgba(1, 1, 1, 0.2)
            colourHovered: Colours.palette.on_surface
            Layout.alignment: Qt.AlignCenter
        }

        PlayerControl {
            iconName: Media.isPlaying ? "pause" : "play_arrow"
            toRun: () => {
                if (Media.activePlayer)
                    Media.activePlayer.togglePlaying();

            }
            width: root.playSize
            height: root.playSize
            radius: root.playRadius
            bgColour: Colours.palette.primary
            colour: Colours.palette.on_primary
            bgColourHovered: Qt.alpha(Colours.palette.primary, 0.85)
            colourHovered: Colours.palette.on_primary
            Layout.alignment: Qt.AlignCenter
        }

        PlayerControl {
            visible: root.showPreviousNext
            iconName: "skip_next"
            toRun: () => {
                if (Media.activePlayer && Media.activePlayer.canGoNext)
                    Media.activePlayer.next();

            }
            width: root.ctrlSize
            height: root.ctrlSize
            radius: root.ctrlRadius
            bgColour: Qt.rgba(0, 0, 0, 0.35)
            colour: Qt.rgba(1, 1, 1, 0.9)
            bgColourHovered: Qt.rgba(1, 1, 1, 0.2)
            colourHovered: Colours.palette.on_surface
            Layout.alignment: Qt.AlignCenter
        }

    }

}
