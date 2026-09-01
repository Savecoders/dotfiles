import QtQuick
import QtQuick.Layouts
import qs.core
import qs.services

Item {
    id: root

    property bool showTimestamps: true
    property bool isVertical: false
    property var barHeights: [0.25, 0.4, 0.7, 0.55, 0.9, 0.65, 0.35, 0.8, 0.95, 0.6, 0.45, 0.75, 1, 0.85, 0.5, 0.3, 0.7, 0.85, 0.6, 0.4, 0.65, 0.9, 0.75, 0.5, 0.8, 0.95, 0.7, 0.4, 0.6, 0.85, 0.7, 0.5, 0.35, 0.6, 0.45, 0.3]
    readonly property int barCount: barHeights.length
    property real barWidth: 3
    property real timelineHeight: 18
    property color primaryColor: Colours.palette.primary
    property color inactiveBarColor: Qt.alpha(Colours.palette.surface_container_highest, 0.85)
    property color needleColor: Colours.palette.on_surface
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

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

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

    RowLayout {
        id: layout

        anchors.fill: parent
        spacing: Styling.spacing.sm

        Text {
            visible: root.showTimestamps && !root.isVertical
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

            Layout.fillWidth: !root.isVertical
            Layout.fillHeight: root.isVertical
            Layout.preferredWidth: root.isVertical ? root.timelineHeight : -1
            Layout.preferredHeight: root.isVertical ? -1 : root.timelineHeight
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

            // Waveform Bars Visualizer (Horizontal)
            Repeater {
                model: !root.isVertical ? root.barCount : 0

                StyledRect {
                    id: wBar

                    readonly property real frac: root.barCount > 1 ? index / (root.barCount - 1) : 0
                    readonly property bool isPast: frac <= root.progressFrac
                    readonly property real barHeightFactor: root.barHeights[index]

                    variant: "common"
                    useDefaultRadius: false
                    border.width: 0
                    width: root.barWidth
                    height: Math.max(3, barHeightFactor * (timelineContainer.height - 4))
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 1.5
                    x: {
                        if (timelineContainer.width <= root.barWidth || root.barCount <= 1)
                            return 0;

                        return (index * (timelineContainer.width - root.barWidth)) / (root.barCount - 1);
                    }
                    color: isPast ? root.primaryColor : root.inactiveBarColor

                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                        }

                    }

                }

            }

            // Waveform Bars Visualizer (Vertical)
            Repeater {
                model: root.isVertical ? root.barCount : 0

                StyledRect {
                    id: vBar

                    readonly property real frac: root.barCount > 1 ? index / (root.barCount - 1) : 0
                    readonly property bool isPast: frac <= root.progressFrac
                    readonly property real barHeightFactor: root.barHeights[index]

                    variant: "common"
                    useDefaultRadius: false
                    border.width: 0
                    height: root.barWidth
                    width: Math.max(3, barHeightFactor * (timelineContainer.width - 4))
                    anchors.horizontalCenter: parent.horizontalCenter
                    radius: 1.5
                    y: {
                        if (timelineContainer.height <= root.barWidth || root.barCount <= 1)
                            return 0;

                        return (index * (timelineContainer.height - root.barWidth)) / (root.barCount - 1);
                    }
                    color: isPast ? root.primaryColor : root.inactiveBarColor

                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                        }

                    }

                }

            }

            // Needle Indicator
            StyledRect {
                id: timelineNeedle

                variant: "common"
                useDefaultRadius: false
                border.width: 0
                width: root.isVertical ? parent.width : 2
                height: root.isVertical ? 2 : parent.height
                radius: 1
                anchors.verticalCenter: root.isVertical ? undefined : parent.verticalCenter
                anchors.horizontalCenter: root.isVertical ? parent.horizontalCenter : undefined
                x: root.isVertical ? 0 : Math.max(0, Math.min(parent.width - width, root.progressFrac * (parent.width - width)))
                y: root.isVertical ? Math.max(0, Math.min(parent.height - height, root.progressFrac * (parent.height - height))) : 0
                color: root.needleColor

                Behavior on x {
                    enabled: !root.isVertical && !root.isDragging && Media.isPlaying

                    NumberAnimation {
                        duration: 450
                        easing.type: Easing.Linear
                    }

                }

                Behavior on y {
                    enabled: root.isVertical && !root.isDragging && Media.isPlaying

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
                    if (root.isVertical) {
                        if (timelineContainer.height <= 0)
                            return 0;

                        return Math.max(0, Math.min(1, mouse.y / timelineContainer.height));
                    } else {
                        if (timelineContainer.width <= 0)
                            return 0;

                        return Math.max(0, Math.min(1, mouse.x / timelineContainer.width));
                    }
                }

                anchors.fill: parent
                anchors.margins: -4
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
            visible: root.showTimestamps && !root.isVertical
            text: root.formatTime(root.trackLength)
            font.pixelSize: Styling.fontSize.sm
            font.family: Config.settings.font ?? "SF Pro Display"
            font.weight: Font.Normal
            color: Colours.palette.on_surface_variant
            Layout.alignment: Qt.AlignVCenter
        }

    }

}
