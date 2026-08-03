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

    property string textValue: ""
    property string message: "Placeholder"
    property var toRun
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
    }

    Text {
        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
        Layout.fillWidth: true
        text: root.message
        font.family: Config.settings.font
        font.pixelSize: 15
        color: Qt.alpha(Colours.palette.on_surface, 0.9)
    }

    TextField {
        id: inputField

        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        Layout.preferredWidth: 200
        Layout.preferredHeight: 32
        text: root.textValue
        placeholderText: "Enter value..."
        color: Colours.palette.on_surface
        font.family: Config.settings.font
        font.pixelSize: 14
        onTextEdited: root.toRun(text)

        background: Rectangle {
            color: Colours.palette.surface_container
            radius: Math.max(4, Config.settings.borderRadius - 12)
            border.color: inputField.activeFocus ? Colours.palette.primary : Qt.alpha(Colours.palette.outline, 0.5)
            border.width: 1
        }

    }

}
