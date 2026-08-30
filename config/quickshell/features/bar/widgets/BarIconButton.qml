import QtQuick
import QtQuick.Layouts
import qs.core
import qs.services

StyledRect {
    id: root

    property bool isVertical: false
    property bool active: false
    property bool collapsible: false
    property string iconGlyph: "notifications"
    property color activeColor: Colours.palette.primary
    property color activeContentColor: Colours.palette.on_primary
    property color inactiveColor: Qt.alpha(Colours.palette.surface, 0.8)
    property color inactiveContentColor: Qt.alpha(Colours.palette.on_surface, 0.8)
    property bool hovered: false
    property string tooltipText: ""
    readonly property bool expanded: !collapsible || active

    signal activated()

    variant: "internalbg"
    useDefaultRadius: false
    implicitWidth: isVertical ? 32 : (expanded ? (hovered ? 48 : 40) : 0)
    implicitHeight: isVertical ? (expanded ? (hovered ? 48 : 40) : 0) : 32
    width: implicitWidth
    height: implicitHeight
    visible: (isVertical ? height : width) > 0
    topLeftRadius: hovered ? Math.max(0, Config.settings.borderRadius - 2) : 4
    topRightRadius: hovered ? Math.max(0, Config.settings.borderRadius - 2) : 4
    bottomLeftRadius: hovered ? Math.max(0, Config.settings.borderRadius - 2) : 4
    bottomRightRadius: hovered ? Math.max(0, Config.settings.borderRadius - 2) : 4
    color: (hovered || active) ? activeColor : inactiveColor
    border.width: 0.5
    border.color: Qt.alpha(Colours.palette.outline, 0.15)

    ColumnLayout {
        width: parent.width
        height: parent.height

        Text {
            color: (root.hovered || root.active) ? root.activeContentColor : root.inactiveContentColor
            text: root.iconGlyph
            font.family: Config.settings.iconFont
            font.weight: 400
            font.pixelSize: Styling.fontSize.lg
            Layout.preferredHeight: 16
            Layout.leftMargin: 0
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            opacity: root.expanded ? 1 : 0
            visible: root.visible

            Behavior on color {
                PropertyAnimation {
                    duration: Config.settings.animationSpeed
                    easing.type: Easing.InSine
                }

            }

            Behavior on opacity {
                PropertyAnimation {
                    duration: Config.settings.animationSpeed
                    easing.type: Easing.InSine
                }

            }

        }

    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: {
            root.hovered = true;
            if (root.tooltipText !== "")
                Tooltip.showItem(root, root.tooltipText);

        }
        onExited: {
            root.hovered = false;
            Tooltip.hide();
        }
        onClicked: root.activated()
    }

    Behavior on bottomLeftRadius {
        PropertyAnimation {
            duration: Config.settings.animationSpeed
            easing.type: Easing.InSine
        }

    }

    Behavior on bottomRightRadius {
        PropertyAnimation {
            duration: Config.settings.animationSpeed
            easing.type: Easing.InSine
        }

    }

    Behavior on topLeftRadius {
        PropertyAnimation {
            duration: Config.settings.animationSpeed
            easing.type: Easing.InSine
        }

    }

    Behavior on topRightRadius {
        PropertyAnimation {
            duration: Config.settings.animationSpeed
            easing.type: Easing.InSine
        }

    }

    Behavior on color {
        PropertyAnimation {
            duration: Config.settings.animationSpeed
            easing.type: Easing.InSine
        }

    }

    Behavior on implicitHeight {
        PropertyAnimation {
            duration: Config.settings.animationSpeed
            easing.type: Easing.InSine
        }

    }

    Behavior on implicitWidth {
        PropertyAnimation {
            duration: Config.settings.animationSpeed
            easing.type: Easing.InSine
        }

    }

}
