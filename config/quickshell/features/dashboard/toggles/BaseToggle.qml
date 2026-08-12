import QtQuick
import QtQuick.Layouts
import qs.core

StyledRect {
    id: root

    default property alias contentData: root.data
    property bool isHovered: false
    property bool isToggled: false
    property int rWidth: 112
    property int rHeight: 87
    property var toRun
    property string bgColour: Colours.palette.primary
    property string colour: Colours.palette.on_primary
    property string bgColourHovered: Colours.palette.primary
    property string colourHovered: Colours.palette.on_primary
    property string bgColourUntoggled: Colours.palette.surface_container
    property string colourUntoggled: Colours.palette.on_surface_variant
    property string bgColourHoveredUntoggled: Colours.palette.primary_container
    property string colourHoveredUntoggled: Colours.palette.on_primary_container

    function getColourBg() {
        if (root.isToggled) {
            if (root.isHovered)
                return root.bgColourHovered;

            return root.bgColour;
        }
        if (root.isHovered)
            return root.bgColourHoveredUntoggled;

        return root.bgColourUntoggled;
    }

    function getColour() {
        if (root.isToggled) {
            if (root.isHovered)
                return root.colourHovered;

            return root.colour;
        }
        if (root.isHovered)
            return root.colourHoveredUntoggled;

        return root.colourUntoggled;
    }

    function getRadius() {
        let baseRadius = Math.max(4, ((Config.settings && Config.settings.borderRadius !== undefined) ? Config.settings.borderRadius : 8) - 6);
        if (root.isHovered)
            return baseRadius + 4;

        if (root.isToggled)
            return baseRadius + 2;
        else
            return baseRadius;
    }

    variant: "common"
    Layout.preferredWidth: isHovered ? rWidth + 10 : rWidth
    Layout.preferredHeight: rHeight
    color: root.getColourBg()
    radius: root.getRadius()

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.isHovered = true
        onExited: root.isHovered = false
        onClicked: {
            if (typeof root.toRun === "function")
                root.toRun();

        }
    }

    Behavior on Layout.preferredWidth {
        PropertyAnimation {
            duration: (Config.settings && Config.settings.animationSpeed !== undefined) ? Config.settings.animationSpeed : 200
            easing.type: Easing.InSine
        }

    }

    Behavior on color {
        PropertyAnimation {
            duration: (Config.settings && Config.settings.animationSpeed !== undefined) ? Config.settings.animationSpeed : 200
            easing.type: Easing.InSine
        }

    }

    Behavior on radius {
        PropertyAnimation {
            duration: (Config.settings && Config.settings.animationSpeed !== undefined) ? Config.settings.animationSpeed : 200
            easing.type: Easing.InSine
        }

    }

}
