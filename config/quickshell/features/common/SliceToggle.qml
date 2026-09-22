import QtQuick
import QtQuick.Layouts
import qs.core

StyledRect {
    id: root

    // Common & card properties
    property bool isToggled: false
    property string text: ""
    property string bigText: ""
    property string smallText: ""
    property string icon: ""
    property string iconCode: ""
    property real iconSize: 24
    property real textSize: Styling.fontSize.body
    property int rWidth: 0
    property int rHeight: 36
    property bool compact: false
    property bool showChevron: false
    property var toRun: null
    property var toRunChevron: null
    // Mode determination
    readonly property bool isCard: bigText !== "" || rWidth > 0 || rHeight > 50 || compact
    // Fallbacks
    readonly property string effectiveIcon: icon !== "" ? icon : iconCode
    readonly property string effectiveTitle: bigText !== "" ? bigText : text
    readonly property string effectiveSubTitle: smallText
    // Palette tokens
    readonly property color fgColor: root.isToggled ? Colours.palette.on_primary : Colours.palette.on_surface
    readonly property color subFgColor: root.isToggled ? Qt.alpha(Colours.palette.on_primary, 0.8) : Colours.palette.on_surface_variant

    signal toggled(bool newState)
    signal chevronClicked()

    function getCardRadius() {
        return Math.max(4, Config.get("borderRadius", 8) - 4);
    }

    variant: "common"
    useDefaultRadius: !root.isCard
    radius: root.isCard ? root.getCardRadius() : (Config.get("borderRadius", 8))
    border.width: 0
    Layout.fillWidth: root.isCard ? (root.rWidth <= 0) : true
    Layout.preferredWidth: root.isCard ? (root.rWidth > 0 ? root.rWidth : -1) : -1
    Layout.preferredHeight: root.isCard ? (root.rHeight > 0 ? root.rHeight : 88) : 36
    implicitHeight: root.isCard ? (root.rHeight > 0 ? root.rHeight : 88) : 36
    color: {
        if (!root.isCard)
            return switchMouseArea.containsMouse ? Transparency.colorFor("popup") : "transparent";

        if (root.isToggled)
            return Colours.palette.primary; // Intentionally opaque accent when active

        if (leftMouseArea.containsMouse || compactMouseArea.containsMouse)
            return Transparency.colorFor("popup");

        return Transparency.colorFor("pane");
    }

    // ==========================================
    // 1. SWITCH MODE (for compact popups / lists)
    // ==========================================
    RowLayout {
        visible: !root.isCard
        anchors.fill: parent
        anchors.leftMargin: Styling.spacing.sm
        anchors.rightMargin: Styling.spacing.sm
        spacing: Styling.spacing.md

        Text {
            visible: root.effectiveIcon !== ""
            text: root.effectiveIcon
            font.family: Config.get("iconFont", "Material Symbols Rounded")
            font.pixelSize: root.iconSize
            color: root.isToggled ? Colours.palette.primary : Colours.palette.on_surface_variant
            Layout.alignment: Qt.AlignVCenter

            Behavior on color {
                PropertyAnimation {
                    duration: Config.get("animationSpeed", 150)
                    easing.type: Easing.OutQuad
                }

            }

        }

        Text {
            Layout.fillWidth: true
            text: root.effectiveTitle
            font.family: Config.get("font", "SF Pro Display")
            font.pixelSize: root.textSize
            font.weight: Font.Medium
            color: Colours.palette.on_surface
            Layout.alignment: Qt.AlignVCenter
        }

        StyledRect {
            id: track

            width: 44
            height: 22
            radius: 11
            useDefaultRadius: false
            border.width: 1
            border.color: root.isToggled ? Colours.palette.primary : Colours.palette.outline_variant
            color: root.isToggled ? Colours.palette.primary : Transparency.colorFor("internalbg")
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

            StyledRect {
                id: thumb

                width: 16
                height: 16
                radius: 8
                useDefaultRadius: false
                border.width: 0
                color: root.isToggled ? Colours.palette.on_primary : Colours.palette.on_surface_variant
                anchors.verticalCenter: parent.verticalCenter
                x: root.isToggled ? (track.width - width - 3) : 3

                Behavior on x {
                    NumberAnimation {
                        duration: Config.get("animationSpeed", 150)
                        easing.type: Easing.OutCubic
                    }

                }

            }

        }

    }

    MouseArea {
        id: switchMouseArea

        visible: !root.isCard
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.isToggled = !root.isToggled;
            root.toggled(root.isToggled);
            if (typeof root.toRun === "function")
                root.toRun();

        }
    }

    // ==========================================
    // 2. COMPACT / CUBE CARD MODE (Vertical layout)
    // ==========================================
    ColumnLayout {
        visible: root.isCard && root.compact
        anchors.centerIn: parent
        width: parent.width - 16
        height: parent.height - 16
        spacing: 6

        Text {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            text: root.effectiveIcon
            font.family: Config.get("iconFont", "Material Symbols Rounded")
            font.pixelSize: root.iconSize
            font.weight: 500
            color: root.fgColor
        }

        Item {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.preferredHeight: compactText.implicitHeight

            Text {
                id: compactText

                anchors.centerIn: parent
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: root.effectiveTitle
                font.family: Config.get("font", "SF Pro Display")
                font.pixelSize: Styling.fontSize.bodyLarge
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
                color: root.fgColor
            }

        }

    }

    MouseArea {
        id: compactMouseArea

        visible: root.isCard && root.compact
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (typeof root.toRun === "function")
                root.toRun();

            root.toggled(!root.isToggled);
        }
    }

    // ==========================================
    // 3. WIDE CARD MODE (Split Left & Chevron Right)
    // ==========================================
    // Right Action Area (Chevron button) - Declared first with highest z-order
    Item {
        id: chevronArea

        visible: root.isCard && !root.compact && root.showChevron
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 56
        z: 10

        StyledRect {
            anchors.fill: parent
            anchors.margins: 4
            radius: Math.max(2, root.getCardRadius() - 2)
            useDefaultRadius: false
            border.width: 0
            color: rightMouseArea.containsMouse ? (root.isToggled ? Qt.alpha(Colours.palette.on_primary, 0.15) : Qt.alpha(Colours.palette.on_surface, 0.08)) : "transparent"

            Behavior on color {
                PropertyAnimation {
                    duration: Config.get("animationSpeed", 150)
                    easing.type: Easing.OutQuad
                }

            }

        }

        Text {
            anchors.centerIn: parent
            text: "chevron_right"
            font.family: Config.get("iconFont", "Material Symbols Rounded")
            font.pixelSize: 24
            font.weight: Font.Medium
            color: root.fgColor
        }

        MouseArea {
            id: rightMouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            preventStealing: true
            z: 10
            onClicked: (mouse) => {
                mouse.accepted = true;
                if (typeof root.toRunChevron === "function")
                    root.toRunChevron();

                root.chevronClicked();
            }
        }

    }

    // Vertical Divider Line - Anchored to chevronArea.left
    StyledRect {
        id: dividerLine

        visible: root.isCard && !root.compact && root.showChevron
        variant: "common"
        useDefaultRadius: false
        border.width: 0
        anchors.right: chevronArea.left
        anchors.verticalCenter: parent.verticalCenter
        width: 1
        height: Math.max(20, parent.height - 32)
        color: root.isToggled ? Qt.alpha(Colours.palette.on_primary, 0.22) : Colours.palette.outline_variant
        z: 5
    }

    // Left Action Area (Icon container + Title/Subtitle)
    Item {
        id: leftArea

        visible: root.isCard && !root.compact
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: root.showChevron ? dividerLine.left : parent.right
        z: 1

        MouseArea {
            id: leftMouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            z: 1
            onClicked: (mouse) => {
                mouse.accepted = true;
                if (typeof root.toRun === "function")
                    root.toRun();

                root.toggled(!root.isToggled);
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: root.showChevron ? 12 : 16
            spacing: 14

            Text {
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                text: root.effectiveIcon
                font.family: Config.get("iconFont", "Material Symbols Rounded")
                font.pixelSize: root.iconSize
                font.weight: 500
                color: root.fgColor
            }

            // Title & Subtitle column
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: root.effectiveTitle
                    font.family: Config.get("font", "SF Pro Display")
                    font.pixelSize: Styling.fontSize.bodyLarge
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    color: root.fgColor
                }

                Text {
                    visible: root.effectiveSubTitle !== ""
                    Layout.fillWidth: true
                    text: root.effectiveSubTitle
                    font.family: Config.get("font", "SF Pro Display")
                    font.pixelSize: Styling.fontSize.sm
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                    color: root.subFgColor
                }

            }

        }

    }

    Behavior on color {
        PropertyAnimation {
            duration: Config.get("animationSpeed", 200)
            easing.type: Easing.InSine
        }

    }

}
