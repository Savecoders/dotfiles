import Quickshell
import Quickshell.Io
import QtQuick.Controls
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import qs.features
import qs.features.bar
import qs.core
import qs.features.common
import qs.services

Scope {
    id: root

    signal finished()

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: barWindow

            property var modelData
            readonly property string pos: Config.settings.bar.position.toLowerCase()
            readonly property bool isVertical: pos === "left" || pos === "right"
            readonly property bool isHorizontal: pos === "top" || pos === "bottom"

            screen: modelData
            color: "transparent"
            implicitWidth: barWindow.isVertical ? metrics.barThickness : 0
            implicitHeight: barWindow.isHorizontal ? metrics.barThickness : 0
            visible: true
            exclusiveZone: metrics.barThickness
            exclusionMode: ExclusionMode.Auto

            function resolvePfpPath(loc) {
                const location = loc || "~/.face";
                const path = location.startsWith("/") ? location : `${Quickshell.env("HOME")}/${location.replace(/^~\//, "")}`;
                return `file://${path}`;
            }

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

            Rectangle {
                id: barBase

                readonly property real marginVal: Config.settings.bar.margin !== undefined ? Config.settings.bar.margin : metrics.marginFallback
                readonly property real dynamicWidth: Math.min(barWindow.width - (marginVal * 2), Math.max(metrics.minBarLength, 56 + (workspacesWidget ? workspacesWidget.width : 160) + (bottomLayout ? bottomLayout.implicitWidth : 180) + metrics.lengthPadding))
                readonly property real dynamicHeight: Math.min(barWindow.height - (marginVal * 2), Math.max(metrics.minBarLength, 56 + (workspacesWidget ? workspacesWidget.height : 160) + (bottomLayout ? bottomLayout.implicitHeight : 180) + metrics.lengthPadding))



                anchors.horizontalCenter: barWindow.isVertical ? undefined : parent.horizontalCenter
                anchors.verticalCenter: barWindow.isVertical ? parent.verticalCenter : undefined
                anchors.left: barWindow.isVertical ? parent.left : undefined
                anchors.right: barWindow.isVertical ? parent.right : undefined
                anchors.top: barWindow.isVertical ? undefined : parent.top
                anchors.bottom: barWindow.isVertical ? undefined : parent.bottom
                anchors.leftMargin: barWindow.isVertical ? marginVal : 0
                anchors.rightMargin: barWindow.isVertical ? marginVal : 0
                anchors.topMargin: barWindow.isVertical ? 0 : marginVal
                anchors.bottomMargin: barWindow.isVertical ? 24 : marginVal
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
                    radius: 100

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

                    Rectangle {
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
                                font.pixelSize: 16
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

                    Rectangle {
                        id: quickActionsButton

                        property bool hovered: false
                        readonly property bool isColoured: hovered || IPCLoader.isDashboardOpen

                        implicitWidth: barWindow.isVertical ? 36 : Math.max(140, statusGroup.implicitWidth + 24)
                        implicitHeight: barWindow.isVertical ? Math.max(104, statusGroup.implicitHeight + 20) : 32
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
                            showBattery: true
                            showBatteryPercentage: true
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
