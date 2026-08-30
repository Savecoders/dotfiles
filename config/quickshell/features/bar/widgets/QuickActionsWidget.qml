import QtQuick
import QtQuick.Layouts
import qs.core
import qs.features
import qs.features.common
import qs.services

StyledRect {
    id: root

    property bool isVertical: false
    property bool hovered: false
    readonly property bool isColoured: hovered || IPCLoader.isDashboardOpen

    variant: "internalbg"
    useDefaultRadius: false
    implicitWidth: isVertical ? metrics.thicknessV : Math.max(metrics.minLength, statusGroup.implicitWidth + metrics.paddingH)
    implicitHeight: isVertical ? Math.max(metrics.minLength, statusGroup.implicitHeight + metrics.paddingV) : metrics.thicknessH
    width: implicitWidth
    height: implicitHeight
    topLeftRadius: hovered ? metrics.radiusInnerSmall : metrics.radiusCollapsed
    topRightRadius: hovered ? metrics.radiusInnerSmall : metrics.radiusCollapsed
    bottomLeftRadius: metrics.radiusInnerSmall
    bottomRightRadius: metrics.radiusInnerSmall
    color: isColoured ? Qt.alpha(Colours.palette.primary, metrics.widgetAlpha) : Qt.alpha(Colours.palette.surface, metrics.widgetAlpha)
    border.width: 0.5
    border.color: Qt.alpha(Colours.palette.outline, 0.15)

    QtObject {
        id: metrics

        readonly property int minLength: 96
        readonly property int paddingH: 24
        readonly property int paddingV: 20
        readonly property int thicknessV: 36
        readonly property int thicknessH: 32
        readonly property real radiusCollapsed: 8
        readonly property real radiusInnerSmall: Math.max(0, Config.settings.borderRadius - 2)
        readonly property real widgetAlpha: 0.8
    }

    QuickStatusGroup {
        id: statusGroup

        anchors.centerIn: parent
        isVertical: root.isVertical
        showClock: true
        showNetwork: true
        showBluetooth: true
        contentColor: root.isColoured ? Colours.palette.on_primary : Qt.alpha(Colours.palette.on_surface, metrics.widgetAlpha)
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: {
            root.hovered = true;
            Tooltip.showItem(root, "Control Center & Dashboard");
        }
        onExited: {
            root.hovered = false;
            Tooltip.hide();
        }
        onClicked: IPCLoader.toggleDashboard()
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
