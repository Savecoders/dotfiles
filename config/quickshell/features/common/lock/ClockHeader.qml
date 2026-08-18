import QtQuick
import QtQuick.Layouts
import qs.core

ColumnLayout {
    id: root

    property Theme theme: themeDefault
    property string timeString: "00:00"
    property string dateString: "Sunday, January 1"
    property string clockFormat: "HH:mm"
    property bool showClock: true
    property bool showDate: true
    property string dateFormat: "dddd, MMMM d"

    spacing: Styling.spacing.xxl

    Theme {
        id: themeDefault
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var d = new Date();
            root.timeString = Qt.formatDateTime(d, root.clockFormat);
            root.dateString = Qt.formatDateTime(d, root.dateFormat);
        }
    }

    Text {
        visible: root.showClock
        text: root.timeString
        color: root.theme.on_surface
        font.family: root.theme.fontFamily
        font.pixelSize: Styling.fontSize.hero
        font.weight: Font.ExtraBold
        Layout.alignment: Qt.AlignHCenter
        style: Text.Outline
        styleColor: Qt.alpha(root.theme.scrim, 0.3)
    }

    Text {
        visible: root.showDate
        text: root.dateString
        color: root.theme.on_surface
        opacity: 0.9
        font.family: root.theme.fontFamily
        font.pixelSize: Styling.fontSize.headline
        font.weight: Font.DemiBold
        Layout.alignment: Qt.AlignHCenter
        style: Text.Outline
        styleColor: Qt.alpha(root.theme.scrim, 0.3)
    }

}
