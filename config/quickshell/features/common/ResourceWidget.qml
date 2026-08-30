import QtQuick
import QtQuick.Layouts
import qs.core
import qs.services

StyledRect {
    id: root

    property bool isVertical: false
    property string tooltipText: ""
    property real progressValue: 0
    property string iconName: ""
    property string labelText: ""
    property color fgColor: Colours.palette.primary

    signal clicked()

    variant: "transparent"
    color: "transparent"
    implicitWidth: isVertical ? (Styling.fontSize.xxl + Styling.spacing.sm) : (contentLayout.implicitWidth + Styling.spacing.sm)
    implicitHeight: isVertical ? (Styling.fontSize.xxl + Styling.spacing.sm) : Styling.fontSize.display
    Component.onDestruction: Tooltip.hide()

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: {
            if (root.tooltipText !== "")
                Tooltip.showItem(root, root.tooltipText);

        }
        onExited: Tooltip.hide()
        onClicked: root.clicked()
    }

    GridLayout {
        id: contentLayout

        anchors.centerIn: parent
        columns: root.isVertical ? 1 : 2
        rows: root.isVertical ? 2 : 1
        columnSpacing: root.isVertical ? Styling.spacing.none : Styling.spacing.md
        rowSpacing: root.isVertical ? Styling.spacing.none : Styling.spacing.none

        CircularProgressIcon {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            width: Styling.fontSize.xxl
            height: Styling.fontSize.xxl
            strokeWidth: 2
            iconPixelSize: Styling.fontSize.sm
            value: root.progressValue
            icon: root.iconName
            fgColor: root.fgColor
        }

        Text {
            visible: !root.isVertical
            text: root.labelText
            font.family: Config.get("font", "SF Pro Display")
            font.pixelSize: Styling.fontSize.body
            font.weight: 600
            color: Colours.palette.on_surface
            horizontalAlignment: Text.AlignHCenter
        }

    }

}
