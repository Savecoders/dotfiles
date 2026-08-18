import QtQuick
import qs.core

StyledRect {
    id: root

    property Theme theme: themeDefault
    property string iconName: "power_settings_new"
    property bool danger: false

    signal clicked()

    variant: "internalbg"
    useDefaultRadius: false
    width: 40
    height: 40
    radius: Math.max(2, root.theme.innerRadius)
    color: mouse.containsMouse ? (root.danger ? root.theme.errorContainer : root.theme.hoverOverlay) : root.theme.pillColor
    border.color: (root.danger && mouse.containsMouse) ? root.theme.error : root.theme.pillBorderColor
    border.width: 1

    Theme {
        id: themeDefault
    }

    Text {
        text: root.iconName
        font.family: root.theme.iconFontFamily
        font.pixelSize: Styling.fontSize.headline
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
