import QtQuick
import QtQuick.Layouts
import qs.core

StyledRect {
    id: root

    property bool isHovered: false
    property bool isToggled: false
    property int rWidth: 0
    property int rHeight: 88
    property var toRun
    property string bigText: ""
    property string smallText: ""
    property string iconCode: "settings"
    property real iconSize: 24
    property bool compact: smallText === ""
    property int bigTextSize: compact ? Styling.fontSize.bodyLarge : Styling.fontSize.lg
    property int smallTextSize: bigTextSize - 2
    property color bgColour: Colours.palette.primary
    property color colour: Colours.palette.on_primary
    property color bgColourHovered: Colours.palette.primary
    property color colourHovered: Colours.palette.on_primary
    property color bgColourUntoggled: Colours.palette.surface_container
    property color colourUntoggled: Colours.palette.on_surface_variant
    property color bgColourHoveredUntoggled: Colours.palette.primary_container
    property color colourHoveredUntoggled: Colours.palette.on_primary_container

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
        return Math.max(4, Config.get("borderRadius", 8) - 4);
    }

    variant: "common"
    Layout.fillWidth: root.rWidth <= 0
    Layout.preferredWidth: root.rWidth > 0 ? root.rWidth : -1
    Layout.preferredHeight: root.rHeight
    color: root.getColourBg()
    radius: root.getRadius()

    // Modes Compact / Cube Layout (Vertical: Icon on Top, Text on Bottom)
    ColumnLayout {
        id: compactLayout

        visible: root.compact
        anchors.centerIn: parent
        width: parent.width - 16
        height: parent.height - 16
        spacing: 4

        Item {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.preferredWidth: root.iconSize
            Layout.preferredHeight: root.iconSize

            Text {
                anchors.centerIn: parent
                text: root.iconCode
                font.family: Config.get("iconFont", "Material Symbols Rounded")
                font.pixelSize: root.iconSize
                font.weight: 500
                color: root.getColour()

                Behavior on color {
                    PropertyAnimation {
                        duration: Config.get("animationSpeed", 200)
                        easing.type: Easing.InSine
                    }

                }

            }

        }

        Item {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.preferredHeight: bigTextItem.implicitHeight

            Text {
                id: bigTextItem

                anchors.centerIn: parent
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: root.bigText
                font.family: Config.get("font", "SF Pro Display")
                font.pixelSize: root.bigTextSize
                font.weight: 500
                wrapMode: Text.WordWrap
                color: root.getColour()

                Behavior on color {
                    PropertyAnimation {
                        duration: Config.get("animationSpeed", 200)
                        easing.type: Easing.InSine
                    }

                }

            }

        }

    }

    // Wide Layout (Horizontal: Icon on Left, Title + Subtitle on Right)
    RowLayout {
        id: wideLayout

        visible: !root.compact
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 14

        Item {
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            Layout.preferredWidth: root.iconSize
            Layout.preferredHeight: root.iconSize

            Text {
                anchors.centerIn: parent
                text: root.iconCode
                font.family: Config.get("iconFont", "Material Symbols Rounded")
                font.pixelSize: root.iconSize
                font.weight: 500
                color: root.getColour()

                Behavior on color {
                    PropertyAnimation {
                        duration: Config.get("animationSpeed", 200)
                        easing.type: Easing.InSine
                    }

                }

            }

        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.bigText
                font.family: Config.get("font", "SF Pro Display")
                font.pixelSize: root.bigTextSize
                font.weight: 500
                elide: Text.ElideRight
                color: root.getColour()

                Behavior on color {
                    PropertyAnimation {
                        duration: Config.get("animationSpeed", 200)
                        easing.type: Easing.InSine
                    }

                }

            }

            Text {
                Layout.fillWidth: true
                visible: root.smallText !== ""
                text: root.smallText
                font.family: Config.get("font", "SF Pro Display")
                font.pixelSize: root.smallTextSize
                font.weight: 500
                elide: Text.ElideRight
                color: Qt.alpha(root.getColour(), 0.7)

                Behavior on color {
                    PropertyAnimation {
                        duration: Config.get("animationSpeed", 200)
                        easing.type: Easing.InSine
                    }

                }

            }

        }

    }

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

    Behavior on color {
        PropertyAnimation {
            duration: Config.get("animationSpeed", 200)
            easing.type: Easing.InSine
        }

    }

}
