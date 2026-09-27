import QtQuick
import QtQuick.Layouts
import qs.core
import qs.services

Item {
    id: root

    property bool isPlaying: Media.isPlaying
    property bool isVertical: false
    property color barColor: Colours.palette.primary
    property color restingColor: Qt.alpha(barColor, 0.4)
    property real minBarSize: 3
    property real maxBarSize: 16
    property real barThickness: 3
    property real barSpacing: 3

    implicitWidth: isVertical ? maxBarSize : (5 * barThickness + 4 * barSpacing)
    implicitHeight: isVertical ? (5 * barThickness + 4 * barSpacing) : maxBarSize

    Repeater {
        model: [
            {
                "durations": [260, 200, 280, 220],
                "targets": [10, 4, 14, 5]
            },
            {
                "durations": [200, 270, 190, 250],
                "targets": [15, 6, 12, 4]
            },
            {
                "durations": [280, 220, 250, 210],
                "targets": [8, 16, 7, 14]
            },
            {
                "durations": [210, 260, 200, 270],
                "targets": [14, 5, 15, 6]
            },
            {
                "durations": [250, 210, 270, 220],
                "targets": [7, 12, 4, 10]
            }
        ]

        delegate: StyledRect {
            id: bar

            readonly property var profile: modelData
            property real currentSize: root.minBarSize

            variant: "common"
            useDefaultRadius: false
            border.width: 0
            radius: root.barThickness / 2
            color: root.isPlaying ? root.barColor : root.restingColor

            x: root.isVertical ? (parent.width - width) / 2 : (index * (root.barThickness + root.barSpacing))
            y: root.isVertical ? (index * (root.barThickness + root.barSpacing)) : (parent.height - height) / 2
            width: root.isVertical ? currentSize : root.barThickness
            height: root.isVertical ? root.barThickness : currentSize

            SequentialAnimation {
                id: playAnim

                loops: Animation.Infinite
                running: root.isPlaying

                NumberAnimation {
                    target: bar
                    property: "currentSize"
                    to: bar.profile.targets[0]
                    duration: bar.profile.durations[0]
                    easing.type: Easing.InOutQuad
                }

                NumberAnimation {
                    target: bar
                    property: "currentSize"
                    to: bar.profile.targets[1]
                    duration: bar.profile.durations[1]
                    easing.type: Easing.InOutQuad
                }

                NumberAnimation {
                    target: bar
                    property: "currentSize"
                    to: bar.profile.targets[2]
                    duration: bar.profile.durations[2]
                    easing.type: Easing.InOutQuad
                }

                NumberAnimation {
                    target: bar
                    property: "currentSize"
                    to: bar.profile.targets[3]
                    duration: bar.profile.durations[3]
                    easing.type: Easing.InOutQuad
                }

                NumberAnimation {
                    target: bar
                    property: "currentSize"
                    to: root.minBarSize
                    duration: 180
                    easing.type: Easing.InOutQuad
                }

            }

            NumberAnimation {
                id: stopAnim

                target: bar
                property: "currentSize"
                to: root.minBarSize
                duration: 200
                easing.type: Easing.OutQuad
            }

            Connections {
                target: root

                function onIsPlayingChanged() {
                    if (root.isPlaying) {
                        stopAnim.stop();
                        playAnim.restart();
                    } else {
                        playAnim.stop();
                        stopAnim.restart();
                    }
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }

            }

        }

    }

}
