import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.core
import qs.features
import qs.features.bar
import qs.features.common
import qs.services

Scope {
    id: root

    signal finished()

    Variants {
        model: Globals.targetScreens

        PanelWindow {
            id: barWindow

            property var modelData
            readonly property string pos: Config.settings.bar.position.toLowerCase()
            readonly property bool isVertical: pos === "left" || pos === "right"
            readonly property bool isHorizontal: pos === "top" || pos === "bottom"
            readonly property real marginVal: Config.settings.bar.margin !== undefined ? Config.settings.bar.margin : metrics.marginFallback

            function resolvePfpPath(loc) {
                const location = loc || "~/.face";
                const path = location.startsWith("/") ? location : `${Quickshell.env("HOME")}/${location.replace(/^~\//, "")}`;
                return `file://${path}`;
            }

            screen: modelData
            color: "transparent"
            implicitWidth: barWindow.isVertical ? (metrics.barThickness + (barWindow.marginVal * 2)) : 0
            implicitHeight: barWindow.isHorizontal ? (metrics.barThickness + (barWindow.marginVal * 2)) : 0
            visible: true
            exclusiveZone: metrics.barThickness + barWindow.marginVal
            exclusionMode: ExclusionMode.Auto

            QtObject {
                id: metrics

                readonly property int barThickness: 40
                readonly property int iconSize: 24
                readonly property int outerPadding: 16
                readonly property int innerSpacing: 8
                readonly property int minBarLength: 120
                readonly property int lengthPadding: 48
                readonly property real marginFallback: 16
                readonly property real opacityFallback: 0.9
                readonly property real widgetAlpha: 0.8
                readonly property real radiusOuter: Config.settings.borderRadius
                readonly property real radiusInner: Math.max(0, Config.settings.borderRadius - 4)
                readonly property real radiusInnerSmall: Math.max(0, Config.settings.borderRadius - 2)
                readonly property real radiusCollapsed: 4
            }

            anchors {
                top: barWindow.pos === 'top' || barWindow.isVertical
                bottom: barWindow.pos === 'bottom' || barWindow.isVertical
                left: barWindow.pos === 'left' || barWindow.isHorizontal
                right: barWindow.pos === 'right' || barWindow.isHorizontal
            }

            StyledRect {
                id: barBase

                readonly property real marginVal: barWindow.marginVal
                readonly property real dynamicWidth: Math.min(barWindow.width - (marginVal * 2), Math.max(metrics.minBarLength, 56 + (workspacesWidget ? workspacesWidget.width : 160) + (bottomLayout ? bottomLayout.implicitWidth : 180) + metrics.lengthPadding))
                readonly property real dynamicHeight: Math.min(barWindow.height - (marginVal * 2), Math.max(metrics.minBarLength, 56 + (workspacesWidget ? workspacesWidget.height : 160) + (bottomLayout ? bottomLayout.implicitHeight : 180) + metrics.lengthPadding))

                variant: "pane"
                useDefaultRadius: false
                anchors.horizontalCenter: barWindow.isVertical ? undefined : parent.horizontalCenter
                anchors.verticalCenter: barWindow.isVertical ? parent.verticalCenter : undefined
                anchors.left: barWindow.isVertical ? (barWindow.pos === "left" ? parent.left : undefined) : undefined
                anchors.right: barWindow.isVertical ? (barWindow.pos === "right" ? parent.right : undefined) : undefined
                anchors.top: barWindow.isVertical ? undefined : (barWindow.pos === "top" ? parent.top : undefined)
                anchors.bottom: barWindow.isVertical ? undefined : (barWindow.pos === "bottom" ? parent.bottom : undefined)
                anchors.leftMargin: barWindow.isVertical ? marginVal : (Config.settings.bar.expand ? marginVal : 0)
                anchors.rightMargin: barWindow.isVertical ? marginVal : (Config.settings.bar.expand ? marginVal : 0)
                anchors.topMargin: barWindow.isVertical ? (Config.settings.bar.expand ? marginVal : 0) : marginVal
                anchors.bottomMargin: barWindow.isVertical ? (Config.settings.bar.expand ? marginVal : 0) : marginVal
                width: barWindow.isVertical ? metrics.barThickness : (Config.settings.bar.expand ? (barWindow.width - (marginVal * 2)) : dynamicWidth)
                height: barWindow.isVertical ? (Config.settings.bar.expand ? (barWindow.height - (marginVal * 2)) : dynamicHeight) : metrics.barThickness
                color: Qt.alpha(Colours.palette.surface, Config.settings.bar.opacity !== undefined ? Config.settings.bar.opacity : metrics.opacityFallback)
                // smoothEdgesShown is false; now the inner buttons follow the
                // same flag through metrics.radiusOuter/Inner/InnerSmall below,
                // instead of always using a fixed radius.
                radius: Config.settings.bar.smoothEdgesShown ? metrics.radiusOuter : 0

                IconImage {
                    id: icon

                    width: metrics.iconSize
                    height: metrics.iconSize
                    opacity: Config.settings.usePfpInsteadOfLogo ? 0 : 1
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.leftMargin: barWindow.isVertical ? (parent.width / 2) - (width / 2) : metrics.outerPadding
                    anchors.topMargin: barWindow.isVertical ? metrics.outerPadding : (parent.height / 2) - (height / 2)
                    source: Qt.resolvedUrl(Quickshell.shellDir + "/assets/icon.png")

                    Behavior on opacity {
                        PropertyAnimation {
                            duration: Config.settings.animationSpeed
                            easing.type: Easing.InSine
                        }

                    }

                }

                ClippingWrapperRectangle {
                    id: pfp

                    width: metrics.iconSize
                    height: metrics.iconSize
                    opacity: Config.settings.usePfpInsteadOfLogo ? 1 : 0
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.leftMargin: barWindow.isVertical ? (parent.width / 2) - (width / 2) - 1 : metrics.outerPadding
                    anchors.topMargin: barWindow.isVertical ? metrics.outerPadding : (parent.height / 2) - (height / 2) - 1
                    color: "transparent"
                    radius: Styling.radius.round

                    Loader {
                        anchors.fill: parent
                        active: !!Config.settings.pfpLocation && Config.settings.pfpLocation !== ""

                        sourceComponent: IconImage {
                            anchors.fill: parent
                            source: resolvePfpPath(Config.settings.pfpLocation)
                            onStatusChanged: {
                                if (status === Image.Error)
                                    source = Qt.resolvedUrl(Quickshell.shellDir + "/assets/icon.png");

                            }
                        }

                    }

                    Behavior on opacity {
                        PropertyAnimation {
                            duration: Config.settings.animationSpeed
                            easing.type: Easing.InSine
                        }

                    }

                }

                WorkspacesWidget {
                    id: workspacesWidget

                    isVertical: barWindow.isVertical
                    bottomLayout: bottomLayout
                }

                Component {
                    id: sysTrayComp

                    SysTray {
                        Layout.alignment: barWindow.isVertical ? Qt.AlignHCenter : Qt.AlignVCenter
                        bar: barWindow
                    }

                }

                Component {
                    id: barIconButtonComp

                    StyledRect {
                        id: iconButton

                        property bool active: false
                        property bool collapsible: false
                        property string iconGlyph: "notifications"
                        property color activeColor: Colours.palette.primary
                        property color activeContentColor: Colours.palette.on_primary
                        property color inactiveColor: Qt.alpha(Colours.palette.surface, metrics.widgetAlpha)
                        property color inactiveContentColor: Qt.alpha(Colours.palette.on_surface, metrics.widgetAlpha)
                        property bool topRadiusFollowsNeighbour: false // e.g. notifications sits under recording
                        property bool hovered: false
                        readonly property bool expanded: !collapsible || active

                        signal activated()

                        variant: "internalbg"
                        useDefaultRadius: false
                        implicitWidth: barWindow.isVertical ? (barBase.width - 8) : (expanded ? (hovered ? 48 : 40) : 0)
                        implicitHeight: barWindow.isVertical ? (expanded ? (hovered ? 48 : 40) : 0) : (barBase.height - 8)
                        width: implicitWidth
                        height: implicitHeight
                        Layout.alignment: barWindow.isVertical ? Qt.AlignHCenter : Qt.AlignVCenter
                        visible: (barWindow.isVertical ? height : width) > 0
                        topLeftRadius: hovered ? metrics.radiusInnerSmall : metrics.radiusCollapsed
                        topRightRadius: hovered ? metrics.radiusInnerSmall : metrics.radiusCollapsed
                        bottomLeftRadius: hovered ? metrics.radiusInnerSmall : metrics.radiusCollapsed
                        bottomRightRadius: hovered ? metrics.radiusInnerSmall : metrics.radiusCollapsed
                        color: (hovered || active) ? activeColor : inactiveColor

                        ColumnLayout {
                            width: parent.width
                            height: parent.height

                            Text {
                                color: (iconButton.hovered || iconButton.active) ? iconButton.activeContentColor : iconButton.inactiveContentColor
                                text: iconButton.iconGlyph
                                font.family: Config.settings.iconFont
                                font.weight: 400
                                font.pixelSize: Styling.fontSize.lg
                                Layout.preferredHeight: 16
                                Layout.leftMargin: 0
                                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                opacity: iconButton.expanded ? 1 : 0
                                visible: iconButton.visible

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
                            onEntered: iconButton.hovered = true
                            onExited: iconButton.hovered = false
                            onClicked: iconButton.activated()
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

                }

                Component {
                    id: recordingComp

                    Loader {
                        sourceComponent: barIconButtonComp
                        onLoaded: {
                            item.collapsible = true;
                            item.active = Qt.binding(() => {
                                return Recorder.isRecordingRunning;
                            });
                            item.iconGlyph = "screen_record";
                            item.activeColor = Colours.palette.error_container;
                            item.activeContentColor = Colours.palette.on_error_container;
                            item.inactiveColor = Qt.alpha(Colours.palette.secondary_fixed, metrics.widgetAlpha);
                            item.activated.connect(() => {
                                return Recorder.stopRecording();
                            });
                        }
                        Layout.alignment: barWindow.isVertical ? Qt.AlignHCenter : Qt.AlignVCenter
                        Layout.preferredWidth: item ? item.implicitWidth : 0
                        Layout.preferredHeight: item ? item.implicitHeight : 0
                    }

                }

                Component {
                    id: notificationComp

                    Loader {
                        sourceComponent: barIconButtonComp
                        onLoaded: {
                            item.collapsible = false;
                            item.iconGlyph = Qt.binding(() => {
                                return Notifications.list.length != 0 ? "notifications_unread" : "notifications";
                            });
                            item.activated.connect(() => {
                                return IPCLoader.toggleNotifications();
                            });
                        }
                        Layout.alignment: barWindow.isVertical ? Qt.AlignHCenter : Qt.AlignVCenter
                        Layout.preferredWidth: item ? item.implicitWidth : 0
                        Layout.preferredHeight: item ? item.implicitHeight : 0
                    }

                }

                Component {
                    id: quickActionsComp

                    StyledRect {
                        id: quickActionsButton

                        property bool hovered: false
                        readonly property bool isColoured: hovered || IPCLoader.isDashboardOpen

                        variant: "internalbg"
                        useDefaultRadius: false
                        implicitWidth: barWindow.isVertical ? 36 : Math.max(96, statusGroup.implicitWidth + 24)
                        implicitHeight: barWindow.isVertical ? Math.max(96, statusGroup.implicitHeight + 20) : 32
                        width: implicitWidth
                        height: implicitHeight
                        Layout.alignment: barWindow.isVertical ? Qt.AlignHCenter : Qt.AlignVCenter
                        topLeftRadius: hovered ? metrics.radiusInnerSmall : 8
                        topRightRadius: hovered ? metrics.radiusInnerSmall : 8
                        bottomLeftRadius: metrics.radiusInnerSmall
                        bottomRightRadius: metrics.radiusInnerSmall
                        color: isColoured ? Qt.alpha(Colours.palette.primary, metrics.widgetAlpha) : Qt.alpha(Colours.palette.surface, metrics.widgetAlpha)

                        QuickStatusGroup {
                            id: statusGroup

                            anchors.centerIn: parent
                            isVertical: barWindow.isVertical
                            showClock: true
                            showNetwork: true
                            showBluetooth: true
                            contentColor: quickActionsButton.isColoured ? Colours.palette.on_primary : Qt.alpha(Colours.palette.on_surface, metrics.widgetAlpha)
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: quickActionsButton.hovered = true
                            onExited: quickActionsButton.hovered = false
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

                }

                Component {
                    id: cpuComp

                    CpuWidget {
                        isVertical: barWindow.isVertical
                    }

                }

                Component {
                    id: ramComp

                    RamWidget {
                        isVertical: barWindow.isVertical
                    }

                }

                Component {
                    id: tempComp

                    TempWidget {
                        isVertical: barWindow.isVertical
                    }

                }

                Component {
                    id: batteryComp

                    BatteryWidget {
                        isVertical: barWindow.isVertical
                    }

                }

                GridLayout {
                    id: bottomLayout

                    columnSpacing: 10
                    rowSpacing: 10
                    columns: barWindow.isVertical ? 1 : 12
                    rows: barWindow.isVertical ? 12 : 1
                    anchors.bottom: barWindow.isVertical ? parent.bottom : undefined
                    anchors.bottomMargin: barWindow.isVertical ? 12 : 0
                    anchors.right: barWindow.isVertical ? undefined : parent.right
                    anchors.rightMargin: barWindow.isVertical ? 0 : 12
                    anchors.horizontalCenter: barWindow.isVertical ? parent.horizontalCenter : undefined
                    anchors.verticalCenter: barWindow.isVertical ? undefined : parent.verticalCenter

                    // NOTE: this switch still duplicates the id list that
                    // BarWidgets.definitionForId already knows about. Ideally
                    // BarWidgets would expose the Component directly (e.g.
                    // BarWidgets.componentForId(id)) so this map only lives in
                    // one place; left as-is here since BarWidgets.qml wasn't
                    // provided, but flagged for follow-up.
                    Repeater {
                        id: rightWidgetsRepeater

                        model: Config.settings.bar.rightWidgets || ["systray", "recording", "notifications", "quickactions"]

                        Loader {
                            id: widgetLoader

                            Layout.alignment: barWindow.isVertical ? Qt.AlignHCenter : Qt.AlignVCenter
                            Layout.preferredWidth: item ? item.implicitWidth : 0
                            Layout.preferredHeight: item ? item.implicitHeight : 0
                            sourceComponent: {
                                if (!BarWidgets.definitionForId(modelData))
                                    return null;

                                switch (modelData) {
                                case "systray":
                                    return sysTrayComp;
                                case "recording":
                                    return recordingComp;
                                case "notifications":
                                    return notificationComp;
                                case "quickactions":
                                    return quickActionsComp;
                                case "cpu":
                                    return cpuComp;
                                case "ram":
                                    return ramComp;
                                case "temp":
                                    return tempComp;
                                case "battery":
                                    return batteryComp;
                                default:
                                    return null;
                                }
                            }
                        }

                    }

                }

                Behavior on width {
                    PropertyAnimation {
                        duration: Config.settings.animationSpeed
                        easing.type: Easing.InSine
                    }

                }

                Behavior on height {
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

            }

            mask: Region {
                item: barBase
            }

        }

    }

}
