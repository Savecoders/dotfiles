import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import qs.core

Item {
    id: root

    property real value: 0 // 0.0 to 1.0
    property string icon: "developer_board"
    property color fgColor: Colours.palette.primary
    property color bgColor: Qt.alpha(Colours.palette.outline, 0.25)
    property color innerCircleColor: "transparent"
    property real strokeWidth: 2
    property int iconPixelSize: Styling.fontSize.label
    property string subText: ""
    property color subTextColor: Colours.palette.on_surface
    property int subTextPixelSize: Styling.fontSize.sm

    implicitWidth: 24
    implicitHeight: 24
    width: implicitWidth
    height: implicitHeight

    // Inner background disk (visible when innerCircleColor is set)
    StyledRect {
        variant: "internalbg"
        useDefaultRadius: false
        border.width: 0
        anchors.fill: parent
        anchors.margins: root.strokeWidth / 2
        radius: Styling.radius.full
        color: root.innerCircleColor
        visible: root.innerCircleColor !== "transparent" && root.innerCircleColor.a > 0
    }
    // Hardware-accelerated GPU progress ring
    Shape {
        id: shape

        anchors.fill: parent
        asynchronous: true
        layer.enabled: true
        layer.samples: 4

        // Track background ring
        ShapePath {
            strokeColor: root.bgColor
            strokeWidth: root.strokeWidth
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: shape.width / 2
                centerY: shape.height / 2
                radiusX: Math.max(0, (Math.min(shape.width, shape.height) - root.strokeWidth) / 2)
                radiusY: Math.max(0, (Math.min(shape.width, shape.height) - root.strokeWidth) / 2)
                startAngle: 0
                sweepAngle: 360
            }
        }

        // Active progress ring
        ShapePath {
            readonly property real progress: Math.max(0, Math.min(1, root.value))
            readonly property bool hasProgress: progress > 0.001

            strokeColor: hasProgress ? root.fgColor : "transparent"
            strokeWidth: root.strokeWidth
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: shape.width / 2
                centerY: shape.height / 2
                radiusX: Math.max(0, (Math.min(shape.width, shape.height) - root.strokeWidth) / 2)
                radiusY: Math.max(0, (Math.min(shape.width, shape.height) - root.strokeWidth) / 2)
                startAngle: -90
                sweepAngle: Math.max(0, Math.min(1, root.value)) * 360
            }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Styling.spacing.xs

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
