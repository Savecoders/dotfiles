import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.core
import qs.services

Slider {
    id: slider

    property int rWidth: 440
    property int rHeight: 30
    property string iconCode: "volume_up"
    property bool isEnabled: true
    property bool isHovered: false

    Layout.fillWidth: true
    Layout.preferredWidth: rWidth
    implicitWidth: rWidth
    implicitHeight: rHeight
    height: rHeight

    background: Item {
        implicitWidth: slider.width
        implicitHeight: slider.height

        // Thin dark horizontal track line for remaining unfilled distance
        Rectangle {
            id: bgTrackLine

            height: 6
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: progressPill.right
            anchors.leftMargin: -parent.height / 2
            anchors.right: parent.right
            radius: 3
            color: slider.isHovered ? Colours.palette.surface_container_high : Qt.alpha(Colours.palette.surface_container, 0.8)

            Behavior on color {
                ColorAnimation {
                    duration: Config.settings.animationSpeed
                }

            }

        }

        // Sliding progress pill container
        Rectangle {
            id: progressPill

            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: Math.max(parent.height, Math.min(parent.width, slider.position * parent.width))
            radius: slider.isHovered ? Math.max(4, Config.settings.borderRadius - 6) : Math.max(4, Config.settings.borderRadius - 10)
            color: {
                if (!slider.isEnabled)
                    return Colours.palette.surface_container;

                return slider.isHovered ? Colours.palette.primary : Qt.alpha(Colours.palette.primary, 0.85);
            }

            // Circular icon container on the left of the pill
            Item {
                width: parent.height
                height: parent.height
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    text: slider.iconCode
                    font.family: Config.settings.iconFont
                    font.pixelSize: 18
                    color: slider.isEnabled ? Colours.palette.on_primary : Qt.alpha(Colours.palette.on_surface, 0.5)

                    Behavior on color {
                        ColorAnimation {
                            duration: Config.settings.animationSpeed
                        }

                    }

                }

            }

            Behavior on color {
                ColorAnimation {
                    duration: Config.settings.animationSpeed
                }

            }

        }

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
        }

    }

    handle: Item {
        width: 0
        height: 0
    }

}
