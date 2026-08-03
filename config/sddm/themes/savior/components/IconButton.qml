import QtQuick
import QtQuick.Controls

Rectangle {
    id: root

    property string text: ""
    property int iconSize: 18
    property color defaultColor: config.surface_container ? config.surface_container : "#1b211e"
    property color hoverColor: config.surface_container_high ? config.surface_container_high : "#252b29"
    property color activeColor: config.primary ? config.primary : "#87d6bd"
    property color textColor: config.on_surface ? config.on_surface : "#dee4e0"

    signal clicked()

    implicitWidth: Math.max(buttonText.implicitWidth + 24, height)
    implicitHeight: 40
    radius: 12
    color: mouseArea.pressed ? activeColor : (mouseArea.containsMouse ? hoverColor : defaultColor)
    border.color: mouseArea.containsMouse ? (config.primary ? config.primary : "#87d6bd") : Qt.rgba(1, 1, 1, 0.08)
    border.width: 1

    Text {
        id: buttonText

        anchors.centerIn: parent
        text: root.text
        color: mouseArea.pressed ? (config.on_primary ? config.on_primary : "#00382c") : root.textColor
        font.family: config.font ? config.font : "SF Pro Display"
        font.pixelSize: 13
        font.weight: Font.Medium
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Behavior on color {
        ColorAnimation {
            duration: 150
        }

    }

    Behavior on border.color {
        ColorAnimation {
            duration: 150
        }

    }

}
