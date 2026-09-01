import QtQuick
import QtQuick.Layouts
import qs.core
import qs.features
import qs.features.common
import qs.features.common.media
import qs.services

StyledRect {
    id: root

    property bool isVertical: false
    property bool hovered: false
    readonly property bool hasPlayer: Media.activePlayer != null

    variant: "internalbg"
    useDefaultRadius: false
    implicitWidth: isVertical ? 32 : (contentLayout.implicitWidth + Styling.spacing.md)
    implicitHeight: isVertical ? (contentLayout.implicitHeight + Styling.spacing.md) : 32
    width: implicitWidth
    height: implicitHeight
    visible: hasPlayer
    color: hovered ? Qt.alpha(Colours.palette.surface_container_high, 0.85) : Qt.alpha(Colours.palette.surface, 0.8)
    border.width: 0.5
    border.color: Qt.alpha(Colours.palette.outline, 0.15)
    topLeftRadius: hovered ? Math.max(0, Config.settings.borderRadius - 2) : 8
    topRightRadius: hovered ? Math.max(0, Config.settings.borderRadius - 2) : 8
    bottomLeftRadius: Math.max(0, Config.settings.borderRadius - 2)
    bottomRightRadius: Math.max(0, Config.settings.borderRadius - 2)

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: {
            root.hovered = true;
            let tip = Media.stableTitle ? (Media.stableTitle + " • " + (Media.stableArtist || "Unknown Artist")) : "Media Player";
            Tooltip.showItem(root, tip);
        }
        onExited: {
            root.hovered = false;
            Tooltip.hide();
        }
        onClicked: {
            Tooltip.hide();
            IPCLoader.toggleDashboard();
        }
    }

    GridLayout {
        id: contentLayout

        anchors.centerIn: parent
        columns: root.isVertical ? 1 : 3
        rows: root.isVertical ? 3 : 1
        columnSpacing: Styling.spacing.sm
        rowSpacing: Styling.spacing.sm

        MediaArt {
            artSize: 24
            artRadius: Styling.radius.full
            Layout.alignment: Qt.AlignCenter
        }

        MediaTimeline {
            isVertical: root.isVertical
            showTimestamps: false
            barWidth: 2
            timelineHeight: 12
            barHeights: [0.3, 0.6, 0.9, 0.5, 0.8, 1, 0.4, 0.7, 0.95, 0.6, 0.35, 0.8, 0.5, 0.75]
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: !root.isVertical
            Layout.fillHeight: root.isVertical
            Layout.preferredWidth: root.isVertical ? 12 : 56
            Layout.preferredHeight: root.isVertical ? 56 : 12
        }

        PlayerControl {
            iconName: Media.isPlaying ? "pause" : "play_arrow"
            toRun: () => {
                if (Media.activePlayer)
                    Media.activePlayer.togglePlaying();

            }
            width: 24
            height: 24
            radius: Styling.radius.full
            bgColour: Colours.palette.primary
            colour: Colours.palette.on_primary
            bgColourHovered: Qt.alpha(Colours.palette.primary, 0.85)
            colourHovered: Colours.palette.on_primary
            Layout.alignment: Qt.AlignCenter
        }

    }

    Behavior on color {
        PropertyAnimation {
            duration: Config.settings.animationSpeed
            easing.type: Easing.InSine
        }

    }

    Behavior on implicitWidth {
        PropertyAnimation {
            duration: Config.settings.animationSpeed
            easing.type: Easing.InSine
        }

    }

    Behavior on implicitHeight {
        PropertyAnimation {
            duration: Config.settings.animationSpeed
            easing.type: Easing.InSine
        }

    }

}
