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

    property var options: []
    property int currentIndex: 0
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

    ComboBox {
        id: control

        model: root.options
        currentIndex: root.currentIndex
        onActivated: (index) => {
            return root.toRun(index);
        }
        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        Layout.preferredWidth: 200
        Layout.preferredHeight: 32

        indicator: Item {
            x: control.width - width - 10
            anchors.verticalCenter: control.verticalCenter
            width: 16
            height: 16

            Text {
                anchors.centerIn: parent
                text: "expand_more"
                font.family: Config.settings.iconFont
                font.pixelSize: 18
                color: Colours.palette.on_surface
            }

        }

        delegate: ItemDelegate {
            id: itemDelegate

            width: control.width - 8
            implicitHeight: 34
            anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined

            contentItem: Text {
                leftPadding: 14
                rightPadding: 14
                text: modelData
                color: itemDelegate.hovered ? Colours.palette.on_primary : Colours.palette.on_surface
                font.family: Config.settings.font
                font.pixelSize: 13
                font.weight: itemDelegate.hovered ? Font.Bold : Font.Normal
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                radius: 8
                color: itemDelegate.hovered ? Colours.palette.primary : "transparent"
            }

        }

        contentItem: Text {
            leftPadding: 12
            rightPadding: 28
            text: control.displayText
            font.family: Config.settings.font
            font.pixelSize: 13
            color: Colours.palette.on_surface
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            implicitWidth: 120
            implicitHeight: 32
            color: Colours.palette.surface_container
            border.color: control.focus ? Colours.palette.primary : Qt.alpha(Colours.palette.outline, 0.5)
            border.width: 1
            radius: Math.max(6, Config.settings.borderRadius - 10)
        }

        popup: Popup {
            y: control.height + 4
            width: control.width
            implicitHeight: Math.min(240, contentItem.implicitHeight + 12)
            padding: 4

            contentItem: ListView {
                clip: true
                spacing: 2
                implicitHeight: contentHeight
                model: control.popup.visible ? control.delegateModel : null
                currentIndex: control.highlightedIndex

                ScrollIndicator.vertical: ScrollIndicator {
                }

            }

            background: Rectangle {
                border.color: Qt.alpha(Colours.palette.outline, 0.4)
                border.width: 1
                radius: Math.max(8, Config.settings.borderRadius - 8)
                color: Colours.palette.surface_container_high
            }

        }

    }

}
