import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.core
import qs.services

Item {
    id: slider

    property string title: ""
    property string iconCode: "volume_up"
    property real from: 0
    property real to: 1
    property real value: 0
    property bool isEnabled: true
    property bool isHovered: false
    property bool showPercent: true
    property int trackHeight: 12
    property int handleHeight: 18
    property int handleWidth: 4
    readonly property real sliderRadius: Config.get("borderRadius", 8)
    readonly property real normalizedProgress: Math.max(0, Math.min(1, (slider.value - slider.from) / Math.max(0.0001, slider.to - slider.from)))
    readonly property string percentString: Math.round(slider.normalizedProgress * 100) + "%"

    signal moved()

    Layout.fillWidth: true
    implicitWidth: 440
    implicitHeight: contentColumn.implicitHeight

    ColumnLayout {
        id: contentColumn

        anchors.fill: parent
        spacing: Styling.spacing.md

        // Top Header Row: [Icon + Title] on the left, [Percentage %] on the right
        RowLayout {
            Layout.fillWidth: true
            spacing: Styling.spacing.md

            RowLayout {
                spacing: Styling.spacing.sm
                Layout.alignment: Qt.AlignVCenter

                Text {
                    text: slider.iconCode
                    font.family: Config.get("iconFont", "Material Symbols Rounded")
                    font.pixelSize: Styling.fontSize.headline
                    color: slider.isEnabled ? (slider.isHovered ? Colours.palette.primary : Colours.palette.on_surface) : Qt.alpha(Colours.palette.on_surface, 0.4)

                    Behavior on color {
                        ColorAnimation {
                            duration: Config.get("animationSpeed", 200)
                        }

                    }

                }

                Text {
                    text: slider.title
                    font.family: Config.get("font", "SF Pro Display")
                    font.pixelSize: Styling.fontSize.lg
                    font.weight: Font.Medium
                    color: slider.isEnabled ? Colours.palette.on_surface : Qt.alpha(Colours.palette.on_surface, 0.4)

                    Behavior on color {
                        ColorAnimation {
                            duration: Config.get("animationSpeed", 200)
                        }

                    }

                }

            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                visible: slider.showPercent
                text: slider.percentString
                font.family: Config.get("font", "SF Pro Display")
                font.pixelSize: Styling.fontSize.md
                font.weight: Font.Normal
                color: slider.isEnabled ? (slider.isHovered ? Colours.palette.primary : Colours.palette.on_surface_variant) : Qt.alpha(Colours.palette.on_surface_variant, 0.4)

                Behavior on color {
                    ColorAnimation {
                        duration: Config.get("animationSpeed", 200)
                    }

                }

            }

        }

        // Bottom Slider Bar Row (Groove + Progress Fill + Vertical Pill Thumb)
        Item {
            id: trackContainer

            Layout.fillWidth: true
            Layout.preferredHeight: slider.handleHeight
            implicitHeight: slider.handleHeight

            StyledRect {
                id: bgTrack

                variant: "internalbg"
                useDefaultRadius: false
                border.width: 0
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: slider.trackHeight
                radius: Math.min(height / 2, slider.sliderRadius)
                color: slider.isHovered ? Colours.palette.surface_container_highest : Qt.alpha(Colours.palette.surface_container_high, 0.85)

                Behavior on color {
                    ColorAnimation {
                        duration: Config.get("animationSpeed", 200)
                    }

                }

            }

            // Active Progress Fill
            StyledRect {
                id: progressFill

                variant: "focus"
                useDefaultRadius: false
                border.width: 0
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                height: slider.trackHeight
                width: Math.max(slider.trackHeight, Math.min(parent.width, slider.normalizedProgress * parent.width))
                radius: Math.min(height / 2, slider.sliderRadius)
                color: {
                    if (!slider.isEnabled)
                        return Colours.palette.surface_container;

                    return slider.isHovered ? Colours.palette.primary : Qt.alpha(Colours.palette.primary, 0.88);
                }

                Behavior on color {
                    ColorAnimation {
                        duration: Config.get("animationSpeed", 200)
                    }

                }

            }

            // Vertical Pill Handle / Thumb Separator
            StyledRect {
                id: handleThumb

                variant: "common"
                useDefaultRadius: false
                border.width: 0
                width: slider.handleWidth
                height: slider.handleHeight
                radius: Math.min(width / 2, slider.sliderRadius)
                anchors.verticalCenter: parent.verticalCenter
                x: Math.max(0, Math.min(parent.width - width, slider.normalizedProgress * (parent.width - width)))
                color: slider.isEnabled ? (slider.isHovered ? Colours.palette.on_primary_container : Colours.palette.primary) : Colours.palette.outline
                opacity: (slider.normalizedProgress > 0.02 && slider.normalizedProgress < 0.98) ? 1 : (slider.isHovered ? 1 : 0.8)

                Behavior on color {
                    ColorAnimation {
                        duration: Config.get("animationSpeed", 200)
                    }

                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Config.get("animationSpeed", 200)
                    }

                }

            }

            // Interactive Gesture Area
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: slider.isHovered = true
                onExited: slider.isHovered = false
                onPressed: (mouse) => {
                    let pos = Math.max(0, Math.min(1, mouse.x / width));
                    slider.value = slider.from + pos * (slider.to - slider.from);
                    slider.moved();
                }
                onPositionChanged: (mouse) => {
                    if (pressed) {
                        let pos = Math.max(0, Math.min(1, mouse.x / width));
                        slider.value = slider.from + pos * (slider.to - slider.from);
                        slider.moved();
                    }
                }
                onWheel: (wheel) => {
                    let step = (slider.to - slider.from) * 0.05;
                    if (wheel.angleDelta.y > 0)
                        slider.value = Math.min(slider.to, slider.value + step);
                    else
                        slider.value = Math.max(slider.from, slider.value - step);
                    slider.moved();
                }
            }

        }

    }

}
