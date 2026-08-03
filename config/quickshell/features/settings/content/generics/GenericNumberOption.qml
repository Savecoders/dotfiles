import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.core
import qs.features.settings.content

RowLayout {
    id: root

    property string message: "Placeholder"
    required property var value
    required property var maxValue
    required property var minValue
    required property var amountIncrease
    required property var amountDecrease
    property bool isFloat: false
    property bool withIcon: false
    property string iconCode: "settings"
    property int iconSize: 20

    spacing: 12
    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
    Layout.preferredWidth: pageWrapper.width
    Layout.preferredHeight: 50

    Text {
        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
        text: root.iconCode
        font.family: Config.settings.iconFont
        font.pixelSize: root.iconSize
        visible: root.withIcon
        color: Qt.alpha(Colours.palette.on_surface, 0.75)

        Behavior on color {
            PropertyAnimation {
                duration: Config.settings.animationSpeed
                easing.type: Easing.InSine
            }

        }

    }

    Text {
        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
        Layout.fillWidth: true
        text: root.message
        font.family: Config.settings.font
        font.pixelSize: 15
        color: Qt.alpha(Colours.palette.on_surface, 0.9)

        Behavior on color {
            PropertyAnimation {
                duration: Config.settings.animationSpeed
                easing.type: Easing.InSine
            }

        }

    }

    GenericNumber {
        value: root.value
        maxValue: root.maxValue
        minValue: root.minValue
        amountIncrease: root.amountIncrease
        amountDecrease: root.amountDecrease
        isFloat: root.isFloat
    }

}
