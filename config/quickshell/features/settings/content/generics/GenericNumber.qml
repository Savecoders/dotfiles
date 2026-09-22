import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.core

StyledRect {
    id: root

    property bool isHovered: false
    required property var value
    required property var maxValue
    required property var minValue
    required property var amountIncrease
    required property var amountDecrease
    required property bool isFloat
    property int decimals: 2

    function format() {
        if (root.isFloat)
            return root.value.toFixed(root.decimals);
        else
            return root.value;
    }

    variant: isHovered ? "popup" : "pane"
    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
    radius: Config.settings.borderRadius - 5
    Layout.preferredHeight: 29
    Layout.preferredWidth: root.isFloat ? 80 : 68

    HoverHandler {
        parent: parent
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad | PointerDevice.Stylus
        onHoveredChanged: {
            root.isHovered = hovered;
        }
    }

    RowLayout {
        width: parent.width - 10
        height: parent.height - 10
        anchors.top: parent.top
        anchors.topMargin: (parent.height / 2) - (height / 2)
        anchors.left: parent.left
        anchors.leftMargin: (parent.width / 2) - (width / 2)

        Text {
            text: "remove"
            font.family: Config.settings.iconFont
            font.pixelSize: Styling.fontSize.md
            color: root.format() == root.minValue ? Qt.alpha(Colours.palette.on_surface, 0.4) : Colours.palette.on_surface
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.isFloat) {
                        if (root.value > root.minValue)
                            root.amountDecrease();

                    } else {
                        if (root.value > root.minValue)
                            root.amountDecrease();

                    }
                }
            }

        }

        Text {
            text: `${root.format()}`
            font.family: Config.settings.font
            font.pixelSize: Styling.fontSize.body
            color: Colours.palette.on_surface
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
        }

        Text {
            text: "add"
            font.family: Config.settings.iconFont
            font.pixelSize: Styling.fontSize.md
            color: root.format() == root.maxValue ? Qt.alpha(Colours.palette.on_surface, 0.4) : Colours.palette.on_surface
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.isFloat) {
                        if (root.value < root.maxValue)
                            root.amountIncrease();

                    } else {
                        if (root.value < root.maxValue)
                            root.amountIncrease();

                    }
                }
            }

        }

    }

    Behavior on color {
        PropertyAnimation {
            duration: Config.settings.animationSpeed
            easing.type: Easing.InSine
        }

    }

}
