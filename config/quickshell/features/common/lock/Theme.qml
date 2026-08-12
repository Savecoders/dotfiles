import QtQuick

QtObject {
    id: root

    property color primary: "#87d6bd"
    property color on_primary: "#00382c"
    property color primaryContainer: "#005141"
    property color on_primary_container: "#a2f2d8"
    property color primaryFixedDim: "#90d1de"
    property color error: "#ffb4ab"
    property color on_error: "#690005"
    property color on_surface: "#dee4e0"
    property color on_surface_variant: "#bfc9c4"
    property color surfaceContainerHigh: "#252b29"
    property color scrim: "#000000"
    property string fontFamily: "SF Pro Display"
    property string iconFontFamily: "Material Symbols Rounded"
    property real cardRadius: 32
    readonly property real innerRadius: Math.max(2, root.cardRadius - 2)
    property color cardColor: Qt.rgba(0, 0, 0, 0.5)
    property color cardBorderColor: Qt.rgba(1, 1, 1, 0.15)
    property color inputColor: Qt.rgba(0, 0, 0, 0.4)
    property color inputBorderColor: Qt.rgba(1, 1, 1, 0.12)
    property color pillColor: Qt.rgba(0, 0, 0, 0.35)
    property color pillBorderColor: Qt.rgba(1, 1, 1, 0.1)
    property color hoverOverlay: Qt.rgba(1, 1, 1, 0.2)
}
