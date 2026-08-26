import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Widgets
import qs.core
import qs.services

ClippingWrapperRectangle {
    id: root

    property int cardHeight: 64
    property real cardRadius: Config.get("borderRadius", 4)
    property color cardColor: Qt.rgba(0, 0, 0, 0.5)
    property color borderColor: Qt.rgba(1, 1, 1, 0.15)
    readonly property bool isCompact: cardHeight <= 70
    readonly property bool hasPlayer: Media.activePlayer != null
    readonly property real trackLength: {
        if (!hasPlayer)
            return 0;

        let p = Media.activePlayer;
        if (p.metadata && p.metadata["mpris:length"] !== undefined) {
            let metaLen = Number(p.metadata["mpris:length"]) || 0;
            if (metaLen > 1000)
                metaLen = metaLen / 1e+06;

            if (metaLen > 2 && isFinite(metaLen))
                return metaLen;

        }
        let pLen = Number(p.length) || 0;
        let pPos = Number(p.position) || 0;
        // Verify length differs from position to discard live streams or placeholder durations
        if (pLen > 2 && isFinite(pLen) && Math.abs(pLen - pPos) > 1.5)
            return pLen;

        return 0;
    }
    readonly property bool hasValidLength: hasPlayer && trackLength > 2 && trackLength < 86400
    property bool isDragging: false
    property real dragPosition: 0
    property real polledPosition: 0
    readonly property real currentPosition: isDragging ? dragPosition : (hasValidLength ? polledPosition : 0)
    readonly property real progressFrac: (hasValidLength && trackLength > 0) ? Math.max(0, Math.min(1, currentPosition / trackLength)) : 0

    function formatTime(sec) {
        let n = Number(sec);
        if (isNaN(n) || n <= 0 || !isFinite(n))
            return "0:00";

        let totalSec = Math.floor(n);
        let h = Math.floor(totalSec / 3600);
        let m = Math.floor((totalSec % 3600) / 60);
        let s = totalSec % 60;
        if (h > 0)
            return h + ":" + (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s);

        return m + ":" + (s < 10 ? "0" + s : s);
    }

    function pollProgress() {
        if (!hasPlayer || !hasValidLength) {
            polledPosition = 0;
            return ;
        }
        polledPosition = Number(Media.activePlayer.position) || 0;
    }

    implicitHeight: cardHeight
    radius: cardRadius
    color: cardColor
    border.color: borderColor
    border.width: 1

    Timer {
        id: posTimer

        interval: 500
        running: Media.isPlaying && root.hasPlayer && root.hasValidLength && !root.isDragging
        repeat: true
        triggeredOnStart: true
        onTriggered: root.pollProgress()
    }

    Connections {
        function onPositionChanged() {
            if (!root.isDragging)
                root.pollProgress();

        }

        function onLengthChanged() {
            if (!root.isDragging)
                root.pollProgress();

        }

        target: Media.activePlayer
    }

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
            ClippingWrapperRectangle {
                id: art

                readonly property real artSize: Math.max(36, root.cardHeight - (root.hasValidLength ? 26 : 20))

                radius: Styling.radius.full
                Layout.preferredWidth: artSize
                Layout.preferredHeight: artSize
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                color: Qt.alpha(Colours.palette.surface_container_highest, 0.8)

                Item {
                    anchors.fill: parent

                    Image {
                        id: albumCover

                        anchors.fill: parent
                        sourceSize: Qt.size(art.artSize, art.artSize)
                        visible: root.hasPlayer && Media.stableArtUrl !== "" && (status === Image.Ready || status === Image.Loading)
                        source: Media.stableArtUrl
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: !root.hasPlayer || Media.stableArtUrl === "" || albumCover.status === Image.Error || albumCover.status === Image.Null
                        color: Colours.palette.outline
                        text: "music_note"
                        font.family: Config.settings.iconFont
                        font.pixelSize: Math.round(art.artSize * 0.45)
                    }

                }

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

                RowLayout {
                    id: timelineRow

                    visible: root.hasValidLength
                    Layout.fillWidth: true
                    Layout.topMargin: 2
                    spacing: Styling.spacing.sm

                    Text {
                        text: root.formatTime(root.currentPosition)
                        font.pixelSize: Styling.fontSize.sm
                        font.family: Config.settings.font ?? "SF Pro Display"
                        font.weight: Font.Normal
                        color: Colours.palette.on_surface_variant
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item {
                        id: timelineContainer

                        property bool isHovered: false
                        readonly property var barHeights: [0.25, 0.4, 0.7, 0.55, 0.9, 0.65, 0.35, 0.8, 0.95, 0.6, 0.45, 0.75, 1, 0.85, 0.5, 0.3, 0.7, 0.85, 0.6, 0.4, 0.65, 0.9, 0.75, 0.5, 0.8, 0.95, 0.7, 0.4, 0.6, 0.85, 0.7, 0.5, 0.35, 0.6, 0.45, 0.3]
                        readonly property int barCount: barHeights.length
                        readonly property real barWidth: 3

                        Layout.fillWidth: true
                        Layout.preferredHeight: 18
                        Layout.alignment: Qt.AlignVCenter

                        // Waveform Bars Visualizer (distributed uniformly across 100% of width)
                        Repeater {
                            model: timelineContainer.barCount

                            StyledRect {
                                id: wBar

                                readonly property real frac: timelineContainer.barCount > 1 ? index / (timelineContainer.barCount - 1) : 0
                                readonly property bool isPast: frac <= root.progressFrac
                                readonly property real barHeightFactor: timelineContainer.barHeights[index]

                                variant: "common"
                                useDefaultRadius: false
                                border.width: 0
                                width: timelineContainer.barWidth
                                height: Math.max(3, barHeightFactor * (timelineContainer.height - 4))
                                anchors.verticalCenter: parent.verticalCenter
                                radius: 1.5
                                x: {
                                    if (timelineContainer.width <= timelineContainer.barWidth || timelineContainer.barCount <= 1)
                                        return 0;

                                    return (index * (timelineContainer.width - timelineContainer.barWidth)) / (timelineContainer.barCount - 1);
                                }
                                color: isPast ? Colours.palette.primary : Qt.alpha(Colours.palette.surface_container_highest, 0.85)

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 100
                                    }

                                }

                            }

                        }

                        // Needle Indicator (aligned 1:1 with progress fraction and waveform)
                        StyledRect {
                            id: timelineNeedle

                            variant: "common"
                            useDefaultRadius: false
                            border.width: 0
                            width: 2
                            height: parent.height
                            radius: 1
                            anchors.verticalCenter: parent.verticalCenter
                            x: Math.max(0, Math.min(parent.width - width, root.progressFrac * (parent.width - width)))
                            color: Colours.palette.on_surface

                            Behavior on x {
                                enabled: !root.isDragging && Media.isPlaying

                                NumberAnimation {
                                    duration: 450
                                    easing.type: Easing.Linear
                                }

                            }

                        }

                        // Interactive Seeking MouseArea
                        MouseArea {
                            id: seekMouseArea

                            function calculateFrac(mouse) {
                                if (timelineContainer.width <= 0)
                                    return 0;

                                return Math.max(0, Math.min(1, mouse.x / timelineContainer.width));
                            }

                            anchors.fill: parent
                            anchors.topMargin: -4
                            anchors.bottomMargin: -4
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: timelineContainer.isHovered = true
                            onExited: timelineContainer.isHovered = false
                            onPressed: (mouse) => {
                                if (root.hasValidLength && root.trackLength > 0) {
                                    root.isDragging = true;
                                    root.dragPosition = calculateFrac(mouse) * root.trackLength;
                                }
                            }
                            onPositionChanged: (mouse) => {
                                if (pressed && root.hasValidLength && root.trackLength > 0)
                                    root.dragPosition = calculateFrac(mouse) * root.trackLength;

                            }
                            onReleased: (mouse) => {
                                if (root.isDragging) {
                                    let targetSec = calculateFrac(mouse) * root.trackLength;
                                    if (Media.activePlayer && (Media.activePlayer.canSeek ?? true))
                                        Media.activePlayer.position = targetSec;

                                    root.polledPosition = targetSec;
                                    root.isDragging = false;
                                }
                            }
                        }

                    }

                    Text {
                        text: root.formatTime(root.trackLength)
                        font.pixelSize: Styling.fontSize.sm
                        font.family: Config.settings.font ?? "SF Pro Display"
                        font.weight: Font.Normal
                        color: Colours.palette.on_surface_variant
                        Layout.alignment: Qt.AlignVCenter
                    }

                }

            }

            // Media Controls
            RowLayout {
                visible: root.hasPlayer
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                spacing: Styling.spacing.sm

                MediaCtrlBtn {
                    iconName: "skip_previous"
                    toRun: () => {
                        if (Media.activePlayer && Media.activePlayer.canGoPrevious)
                            Media.activePlayer.previous();

                    }
                }

                PlayerControl {
                    iconName: Media.isPlaying ? "pause" : "play_arrow"
                    toRun: () => {
                        if (Media.activePlayer)
                            Media.activePlayer.togglePlaying();

                    }
                    width: root.isCompact ? 30 : 36
                    height: root.isCompact ? 30 : 36
                    radius: Math.max(2, root.cardRadius - 2)
                    bgColour: Colours.palette.primary
                    colour: Colours.palette.on_primary
                    bgColourHovered: Qt.alpha(Colours.palette.primary, 0.85)
                    colourHovered: Colours.palette.on_primary
                }

                MediaCtrlBtn {
                    iconName: "skip_next"
                    toRun: () => {
                        if (Media.activePlayer && Media.activePlayer.canGoNext)
                            Media.activePlayer.next();

                    }
                }

            }

        }

    }

    component MediaCtrlBtn: PlayerControl {
        readonly property real ctrlSize: root.isCompact ? 30 : 32

        width: ctrlSize
        height: ctrlSize
        radius: Math.max(2, root.cardRadius - 2)
        bgColour: Qt.rgba(0, 0, 0, 0.35)
        colour: Qt.rgba(1, 1, 1, 0.9)
        bgColourHovered: Qt.rgba(1, 1, 1, 0.2)
        colourHovered: Colours.palette.on_surface
    }

}
