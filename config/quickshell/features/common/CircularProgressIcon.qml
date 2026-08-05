import QtQuick
import QtQuick.Layouts
import qs.core

Item {
    id: root

    property real value: 0 // 0.0 to 1.0
    property string icon: "developer_board"
    property color fgColor: Colours.palette.primary
    property color bgColor: Qt.alpha(Colours.palette.outline, 0.25)
    property color innerCircleColor: "transparent"
    property real strokeWidth: 2
    property int iconPixelSize: 12
    property string subText: ""
    property color subTextColor: Colours.palette.on_surface
    property int subTextPixelSize: 11

    implicitWidth: 24
    implicitHeight: 24
    width: implicitWidth
    height: implicitHeight
    onValueChanged: canvas.requestPaint()
    onFgColorChanged: canvas.requestPaint()
    onBgColorChanged: canvas.requestPaint()
    onInnerCircleColorChanged: canvas.requestPaint()

    // Inner background disk (visible when innerCircleColor is set)
    Rectangle {
        anchors.fill: parent
        anchors.margins: root.strokeWidth / 2
        radius: 1000
        color: root.innerCircleColor
        visible: root.innerCircleColor !== "transparent" && root.innerCircleColor.a > 0
    }

    Canvas {
        id: canvas

        anchors.fill: parent
        renderTarget: Canvas.Image
        onPaint: {
            let ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            let cx = width / 2;
            let cy = height / 2;
            let r = (Math.min(width, height) - root.strokeWidth) / 2;
            let start = -Math.PI / 2;
            let progress = Math.max(0, Math.min(1, root.value));
            let end = start + (2 * Math.PI * progress);
            ctx.lineWidth = root.strokeWidth;
            ctx.lineCap = "round";
            // Track background ring
            ctx.strokeStyle = root.bgColor;
            ctx.beginPath();
            ctx.arc(cx, cy, r, 0, 2 * Math.PI);
            ctx.stroke();
            // Progress ring
            if (progress > 0) {
                ctx.strokeStyle = root.fgColor;
                ctx.beginPath();
                ctx.arc(cx, cy, r, start, end);
                ctx.stroke();
            }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 2

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.icon
            font.family: Config.settings.iconFont
            font.pixelSize: root.iconPixelSize
            color: root.fgColor
        }

        Text {
            visible: root.subText !== ""
            Layout.alignment: Qt.AlignHCenter
            text: root.subText
            font.family: Config.settings.font
            font.pixelSize: root.subTextPixelSize
            font.weight: Font.Bold
            color: root.subTextColor
            elide: Text.ElideRight
        }

    }

}
