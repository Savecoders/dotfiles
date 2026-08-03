import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property string hours: "00"
    property string minutes: "00"

    spacing: -20

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var date = new Date();
            root.hours = Qt.formatDateTime(date, "HH");
            root.minutes = Qt.formatDateTime(date, "mm");
        }
    }

    Text {
        text: root.hours
        color: config.primary ? config.primary : "#87d6bd"
        font.family: config.font ? config.font : "SF Pro Display"
        font.pixelSize: 140
        font.weight: Font.Black
        Layout.alignment: Qt.AlignHCenter
        style: Text.Outline
        styleColor: Qt.rgba(0, 0, 0, 0.3)
    }

    Text {
        text: root.minutes
        color: config.primary ? config.primary : "#87d6bd"
        font.family: config.font ? config.font : "SF Pro Display"
        font.pixelSize: 140
        font.weight: Font.Black
        Layout.alignment: Qt.AlignHCenter
        style: Text.Outline
        styleColor: Qt.rgba(0, 0, 0, 0.3)
    }

}
