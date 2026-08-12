import QtQuick

Rectangle {
    id: root

    property Theme theme: themeDefault
    property string iconName: ""
    property bool danger: false

    signal clicked()

    width: 40
    height: 40
    radius: Math.max(2, root.theme.innerRadius)
    color: mouse.containsMouse ? (root.danger ? Qt.alpha(root.theme.error, 0.4) : root.theme.hoverOverlay) : root.theme.pillColor
    border.color: root.danger ? (mouse.containsMouse ? root.theme.error : root.theme.pillBorderColor) : root.theme.pillBorderColor
    border.width: 1

    Theme {
        id: themeDefault
    }

    Text {
        text: root.iconName
        font.family: root.theme.iconFontFamily
        font.pixelSize: 20
        color: root.danger && mouse.containsMouse ? root.theme.error : root.theme.on_surface
        anchors.centerIn: parent
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

}
