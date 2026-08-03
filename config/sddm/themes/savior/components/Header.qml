import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property string timeString: "00:00"
    property string dateString: "Sunday, January 1"

    spacing: 6

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var d = new Date();
            root.timeString = Qt.formatDateTime(d, config.clockFormat ? config.clockFormat : "HH:mm");
            root.dateString = Qt.formatDateTime(d, config.dateFormat ? config.dateFormat : "dddd, MMMM d");
        }
    }

    Text {
        text: root.timeString
        color: config.on_surface ? config.on_surface : "#dee4e0"
        font.family: config.font ? config.font : "SF Pro Display"
        font.pixelSize: 104
        font.weight: Font.Bold
        Layout.alignment: Qt.AlignHCenter
        style: Text.Outline
        styleColor: Qt.rgba(0, 0, 0, 0.3)
    }

    Text {
        text: root.dateString
        color: config.on_surface ? config.on_surface : "#dee4e0"
        opacity: 0.9
        font.family: config.font ? config.font : "SF Pro Display"
        font.pixelSize: 32
        font.weight: Font.DemiBold
        Layout.alignment: Qt.AlignHCenter
        style: Text.Outline
        styleColor: Qt.rgba(0, 0, 0, 0.3)
    }

}
