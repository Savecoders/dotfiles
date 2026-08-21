import QtQuick
import QtQuick.Layouts
import qs.core

StyledRect {
    id: root

    property string text: ""
    property string icon: ""
    property string btnVariant: "primary" // "primary", "secondary", "danger", "iconOnly"
    property real iconSize: Styling.fontSize.md
    property real textSize: Styling.fontSize.body
    property int fontWeight: (btnVariant === "primary" || btnVariant === "danger") ? Font.Bold : Font.Medium
    property string accessibleLabel: ""
    property bool hovered: mouseArea.containsMouse
    property bool pressed: mouseArea.pressed
    // Default primitives
    readonly property real defaultHeight: 38
    readonly property real pressedScale: 0.98
    readonly property int pressAnimDuration: 80 // Faster response for tactile press feedback
    readonly property int borderWidth: 1
    // Centralized style palette map per variant
    readonly property var variantStyle: ({
        "primary": {
            "bg": Colours.palette.primary,
            "bgHover": Colours.palette.primary_container,
            "bgPressed": Colours.palette.inverse_primary,
            "border": Colours.palette.primary,
            "borderHover": Colours.palette.primary,
            "fg": Colours.palette.on_primary,
            "fgHover": Colours.palette.on_primary_container,
            "fgPressed": Colours.palette.on_primary,
            "iconFg": Colours.palette.on_primary,
            "iconFgHover": Colours.palette.on_primary_container,
            "iconFgPressed": Colours.palette.on_primary
        },
        "danger": {
            "bg": Colours.palette.error,
            "bgHover": Colours.palette.error_container,
            "bgPressed": Colours.palette.on_error_container,
            "border": Colours.palette.error,
            "borderHover": Colours.palette.error,
            "fg": Colours.palette.on_error,
            "fgHover": Colours.palette.on_error_container,
            "fgPressed": Colours.palette.on_error,
            "iconFg": Colours.palette.on_error,
            "iconFgHover": Colours.palette.on_error_container,
            "iconFgPressed": Colours.palette.on_error
        },
        "secondary": {
            "bg": Colours.palette.surface_container_low,
            "bgHover": Colours.palette.surface_container_high,
            "bgPressed": Colours.palette.surface_container_highest,
            "border": Colours.palette.outline_variant,
            "borderHover": Colours.palette.outline,
            "fg": Colours.palette.on_surface,
            "fgHover": Colours.palette.on_surface,
            "fgPressed": Colours.palette.on_surface,
            "iconFg": Colours.palette.primary,
            "iconFgHover": Colours.palette.primary,
            "iconFgPressed": Colours.palette.primary
        },
        "iconOnly": {
            "bg": Colours.palette.surface_container_low,
            "bgHover": Colours.palette.surface_container_high,
            "bgPressed": Colours.palette.surface_container_highest,
            "border": Colours.palette.outline_variant,
            "borderHover": Colours.palette.outline,
            "fg": Colours.palette.on_surface,
            "fgHover": Colours.palette.on_surface,
            "fgPressed": Colours.palette.on_surface,
            "iconFg": Colours.palette.on_surface,
            "iconFgHover": Colours.palette.primary,
            "iconFgPressed": Colours.palette.primary
        }
    })
    readonly property var currentStyle: variantStyle[btnVariant] || variantStyle["primary"]

    signal clicked()

    Component.onCompleted: {
        if (!variantStyle[btnVariant])
            console.warn(`MButton: unknown btnVariant "${btnVariant}", falling back to "primary".`);

    }
    useDefaultRadius: true
    implicitHeight: defaultHeight
    implicitWidth: btnVariant === "iconOnly" ? defaultHeight : (contentRow.implicitWidth + (Styling.spacing.md * 2))
    Layout.preferredHeight: defaultHeight
    Layout.preferredWidth: btnVariant === "iconOnly" ? defaultHeight : -1
    Layout.fillWidth: btnVariant !== "iconOnly"
    scale: pressed ? pressedScale : 1
    opacity: root.enabled ? 1 : 0.45
    border.width: borderWidth
    color: pressed ? currentStyle.bgPressed : (hovered ? currentStyle.bgHover : currentStyle.bg)
    border.color: (hovered || pressed) ? currentStyle.borderHover : currentStyle.border
    // Accessibility and Keyboard navigation
    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    Accessible.name: accessibleLabel !== "" ? accessibleLabel : (root.text !== "" ? root.text : root.icon)
    Keys.onReturnPressed: {
        if (root.enabled)
            root.clicked();

    }
    Keys.onSpacePressed: {
        if (root.enabled)
            root.clicked();

    }

    RowLayout {
        id: contentRow

        anchors.centerIn: parent
        spacing: Styling.spacing.sm

        Text {
            visible: root.icon !== ""
            text: root.icon
            font.family: Config.settings.iconFont
            font.pixelSize: root.iconSize
            color: root.pressed ? root.currentStyle.iconFgPressed : (root.hovered ? root.currentStyle.iconFgHover : root.currentStyle.iconFg)
            Layout.alignment: Qt.AlignVCenter

            Behavior on color {
                PropertyAnimation {
                    duration: Config.settings.animationSpeed ?? 150
                    easing.type: Easing.OutQuad
                }

            }

        }

        Text {
            visible: root.text !== ""
            text: root.text
            font.family: Config.settings.font
            font.pixelSize: root.textSize
            font.weight: root.fontWeight
            color: root.pressed ? root.currentStyle.fgPressed : (root.hovered ? root.currentStyle.fgHover : root.currentStyle.fg)
            Layout.alignment: Qt.AlignVCenter

            Behavior on color {
                PropertyAnimation {
                    duration: Config.settings.animationSpeed ?? 150
                    easing.type: Easing.OutQuad
                }

            }

        }

    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: root.enabled
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (root.enabled)
                root.clicked();

        }
    }

    Behavior on color {
        PropertyAnimation {
            duration: Config.settings.animationSpeed ?? 150
            easing.type: Easing.OutQuad
        }

    }

    Behavior on border.color {
        PropertyAnimation {
            duration: Config.settings.animationSpeed ?? 150
            easing.type: Easing.OutQuad
        }

    }

    Behavior on opacity {
        PropertyAnimation {
            duration: Config.settings.animationSpeed ?? 150
            easing.type: Easing.OutQuad
        }

    }

    Behavior on scale {
        NumberAnimation {
            duration: root.pressAnimDuration
            easing.type: Easing.OutQuad
        }

    }

}
