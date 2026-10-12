import QtQuick
import QtQuick.Layouts
import qs.core
import qs.features
import qs.services

StyledRect {
    id: root

    property bool isVertical: false
    property bool hovered: false
    readonly property bool isColoured: hovered || IPCLoader.isCalendarOpen
    readonly property color contentColor: isColoured ? Colours.palette.on_primary : Qt.alpha(Colours.palette.on_surface, metrics.widgetAlpha)

    variant: "internalbg"
    useDefaultRadius: false
    implicitWidth: isVertical ? metrics.thicknessV : (contentRow.implicitWidth + metrics.paddingH)
    implicitHeight: isVertical ? (contentCol.implicitHeight + metrics.paddingV) : metrics.thicknessH
    width: implicitWidth
    height: implicitHeight
    topLeftRadius: hovered ? metrics.radiusInnerSmall : metrics.radiusCollapsed
    topRightRadius: hovered ? metrics.radiusInnerSmall : metrics.radiusCollapsed
    bottomLeftRadius: metrics.radiusInnerSmall
    bottomRightRadius: metrics.radiusInnerSmall
    color: isColoured ? Transparency.applyAlpha(Colours.palette.primary, 0.95) : Transparency.colorFor(variant)
    border.width: 0.5
    border.color: Qt.alpha(Colours.palette.outline, 0.15)

    QtObject {
        id: metrics

        readonly property int paddingH: 20
        readonly property int paddingV: 14
        readonly property int thicknessV: 36
        readonly property int thicknessH: 32
        readonly property real radiusCollapsed: 8
        readonly property real radiusInnerSmall: Math.max(0, Config.settings.borderRadius - 2)
        readonly property real widgetAlpha: 0.85
    }

    RowLayout {
        id: contentRow

        visible: !root.isVertical
        anchors.centerIn: parent
        spacing: Styling.spacing.sm

        Text {
            text: Time.time
            font.family: Config.settings.font
            font.pixelSize: Styling.fontSize.sm
            font.weight: Font.DemiBold
            color: root.contentColor
            Layout.alignment: Qt.AlignVCenter

            Behavior on color {
                PropertyAnimation {
                    duration: Config.settings.animationSpeed
                    easing.type: Easing.InSine
                }

            }

        }

        Text {
            text: "•"
            font.pixelSize: Styling.fontSize.xs
            color: Qt.alpha(root.contentColor, 0.5)
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: Time.date
            font.family: Config.settings.font
            font.pixelSize: Styling.fontSize.sm
            color: Qt.alpha(root.contentColor, 0.5)
            Layout.alignment: Qt.AlignVCenter

            Behavior on color {
                PropertyAnimation {
                    duration: Config.settings.animationSpeed
                    easing.type: Easing.InSine
                }

            }

        }

    }

    // Vertical layout: stacked time + compact date
    ColumnLayout {
        id: contentCol

        visible: root.isVertical
        anchors.centerIn: parent
        spacing: 1

        Text {
            text: Time.hour
            font.family: Config.settings.font
            font.pixelSize: Styling.fontSize.sm
            font.weight: Font.DemiBold
            color: root.contentColor
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter

            Behavior on color {
                PropertyAnimation {
                    duration: Config.settings.animationSpeed
                    easing.type: Easing.InSine
                }

            }

        }

        Text {
            text: Time.minute
            font.family: Config.settings.font
            font.pixelSize: Styling.fontSize.sm
            font.weight: Font.DemiBold
            color: root.contentColor
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter

            Behavior on color {
                PropertyAnimation {
                    duration: Config.settings.animationSpeed
                    easing.type: Easing.InSine
                }

            }

        }

        Text {
            text: "--"
            font.pixelSize: Styling.fontSize.xs
            color: Qt.alpha(root.contentColor, 0.5)
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 2
        }

        Text {
            text: {
                let d = new Date();
                return Qt.formatDate(d, "dd");
            }
            font.family: Config.settings.font
            font.pixelSize: Styling.fontSize.sm
            color: Qt.alpha(root.contentColor, 0.75)
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 2

            Behavior on color {
                PropertyAnimation {
                    duration: Config.settings.animationSpeed
                    easing.type: Easing.InSine
                }

            }

        }

        Text {
            text: {
                let d = new Date();
                return Qt.formatDate(d, "MMM");
            }
            font.family: Config.settings.font
            font.pixelSize: Styling.fontSize.xs
            color: Qt.alpha(root.contentColor, 0.75)
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 2

            Behavior on color {
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
            Tooltip.showItem(root, Time.fullDate);
        }
        onExited: {
            root.hovered = false;
            Tooltip.hide();
        }
        onClicked: {
            Tooltip.hide();
            IPCLoader.toggleCalendarAt(root);
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

}
