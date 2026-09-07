import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.core
import qs.features
import qs.features.bar
import qs.features.bar.widgets
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
            readonly property string pos: Config.barPosition
            readonly property bool isVertical: pos === "left" || pos === "right"
            readonly property bool isHorizontal: pos === "top" || pos === "bottom"
            readonly property bool isFloating: Config.get("bar.floating", true)
            readonly property real marginVal: Config.settings.bar.margin !== undefined ? Config.settings.bar.margin : metrics.marginFallback
            readonly property real edgeGap: (Config.settings.desktop.desktopRoundingShown) ? Config.get("desktop.desktopGap", 4) : 0
            readonly property real effectiveMargin: isFloating ? marginVal : edgeGap

            screen: modelData
            color: "transparent"
            implicitWidth: barWindow.isVertical ? (metrics.barThickness + (barWindow.isFloating ? (barWindow.marginVal * 2) : barWindow.edgeGap)) : 0
            implicitHeight: barWindow.isHorizontal ? (metrics.barThickness + (barWindow.isFloating ? (barWindow.marginVal * 2) : barWindow.edgeGap)) : 0
            visible: true
            exclusiveZone: metrics.barThickness + barWindow.effectiveMargin
            exclusionMode: ExclusionMode.Auto

            IdleInhibitor {
                window: barWindow
                enabled: Idle.enabled && Idle.keepAwake
            }

            QtObject {
                id: metrics

                readonly property int barThickness: 40
                readonly property int iconSize: 24
                readonly property int outerPadding: 16
                readonly property int innerSpacing: 8
                readonly property int minBarLength: 120
                readonly property int lengthPadding: 48
                readonly property int iconLeadingOffset: 56
                readonly property int workspacesFallbackLength: 160
                readonly property int bottomLayoutFallbackLength: 180
                readonly property real marginFallback: 16
                readonly property real opacityFallback: 0.9
                readonly property real radiusOuter: Config.settings.borderRadius
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
                readonly property real dynamicWidth: Math.min(barWindow.width - (marginVal * 2), Math.max(metrics.minBarLength, metrics.iconLeadingOffset + (workspacesWidget ? workspacesWidget.width : metrics.workspacesFallbackLength) + (bottomLayout ? bottomLayout.implicitWidth : metrics.bottomLayoutFallbackLength) + metrics.lengthPadding))
                readonly property real dynamicHeight: Math.min(barWindow.height - (marginVal * 2), Math.max(metrics.minBarLength, metrics.iconLeadingOffset + (workspacesWidget ? workspacesWidget.height : metrics.workspacesFallbackLength) + (bottomLayout ? bottomLayout.implicitHeight : metrics.bottomLayoutFallbackLength) + metrics.lengthPadding))
                readonly property var widgetComponents: ({
                    "systray": sysTrayComp,
                    "recording": recordingComp,
                    "notifications": notificationComp,
                    "quickactions": quickActionsComp,
                    "cpu": cpuComp,
                    "ram": ramComp,
                    "temp": tempComp,
                    "battery": batteryComp,
                    "weather": weatherComp,
                    "media": mediaComp
                })

                function cornerRadius(corner) {
                    if (!Config.settings.bar.smoothEdgesShown)
                        return 0;

                    if (barWindow.isFloating)
                        return metrics.radiusOuter;

                    const roundedCorners = {
                        "top": ["bl", "br"],
                        "bottom": ["tl", "tr"],
                        "left": ["tr", "br"],
                        "right": ["tl", "bl"]
                    }[barWindow.pos] ?? [];
                    return roundedCorners.includes(corner) ? metrics.radiusOuter : 0;
                }

                variant: "pane"
                useDefaultRadius: false
                anchors.horizontalCenter: barWindow.isVertical ? undefined : parent.horizontalCenter
                anchors.verticalCenter: barWindow.isVertical ? parent.verticalCenter : undefined
                anchors.left: barWindow.isVertical ? (barWindow.pos === "left" ? parent.left : undefined) : undefined
                anchors.right: barWindow.isVertical ? (barWindow.pos === "right" ? parent.right : undefined) : undefined
                anchors.top: barWindow.isVertical ? undefined : (barWindow.pos === "top" ? parent.top : undefined)
                anchors.bottom: barWindow.isVertical ? undefined : (barWindow.pos === "bottom" ? parent.bottom : undefined)
                anchors.leftMargin: barWindow.isVertical ? (barWindow.pos === "left" ? barWindow.effectiveMargin : marginVal) : (Config.settings.bar.expand ? marginVal : 0)
                anchors.rightMargin: barWindow.isVertical ? (barWindow.pos === "right" ? barWindow.effectiveMargin : marginVal) : (Config.settings.bar.expand ? marginVal : 0)
                anchors.topMargin: barWindow.isVertical ? (Config.settings.bar.expand ? marginVal : 0) : (barWindow.pos === "top" ? barWindow.effectiveMargin : marginVal)
                anchors.bottomMargin: barWindow.isVertical ? (Config.settings.bar.expand ? marginVal : 0) : (barWindow.pos === "bottom" ? barWindow.effectiveMargin : marginVal)
                width: barWindow.isVertical ? metrics.barThickness : (Config.settings.bar.expand ? (barWindow.width - (marginVal * 2)) : dynamicWidth)
                height: barWindow.isVertical ? (Config.settings.bar.expand ? (barWindow.height - (marginVal * 2)) : dynamicHeight) : metrics.barThickness
                color: Qt.alpha(Colours.palette.surface, Config.settings.bar.opacity !== undefined ? Config.settings.bar.opacity : metrics.opacityFallback)
                border.width: barWindow.isFloating ? 1 : 0
                border.color: barWindow.isFloating ? Qt.alpha(Colours.palette.outline, 0.15) : "transparent"
                topLeftRadius: cornerRadius("tl")
                topRightRadius: cornerRadius("tr")
                bottomLeftRadius: cornerRadius("bl")
                bottomRightRadius: cornerRadius("br")
                radius: Config.settings.bar.smoothEdgesShown ? metrics.radiusOuter : 0

                AvatarWidget {
                    id: avatarWidget

                    isVertical: barWindow.isVertical
                    iconSize: metrics.iconSize
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.leftMargin: barWindow.isVertical ? (parent.width / 2) - (width / 2) : metrics.outerPadding
                    anchors.topMargin: barWindow.isVertical ? metrics.outerPadding : (parent.height / 2) - (height / 2)
                }

                WorkspacesWidget {
                    id: workspacesWidget

                    isVertical: barWindow.isVertical
                    bottomLayout: bottomLayout
                }

                Component {
                    id: sysTrayComp

                    SysTrayWidget {
                        Layout.alignment: barWindow.isVertical ? Qt.AlignHCenter : Qt.AlignVCenter
                        bar: barWindow
                    }

                }

                Component {
                    id: recordingComp

                    RecordingWidget {
                        Layout.alignment: barWindow.isVertical ? Qt.AlignHCenter : Qt.AlignVCenter
                        isVertical: barWindow.isVertical
                    }

                }

                Component {
                    id: notificationComp

                    NotificationWidget {
                        Layout.alignment: barWindow.isVertical ? Qt.AlignHCenter : Qt.AlignVCenter
                        isVertical: barWindow.isVertical
                    }

                }

                Component {
                    id: quickActionsComp

                    QuickActionsWidget {
                        Layout.alignment: barWindow.isVertical ? Qt.AlignHCenter : Qt.AlignVCenter
                        isVertical: barWindow.isVertical
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

                Component {
                    id: weatherComp

                    WeatherWidget {
                        isVertical: barWindow.isVertical
                    }

                }

                Component {
                    id: mediaComp

                    MediaWidget {
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

                    Repeater {
                        id: rightWidgetsRepeater

                        model: Config.settings.bar.rightWidgets || ["systray", "weather", "recording", "notifications", "quickactions"]

                        Loader {
                            id: widgetLoader

                            Layout.alignment: barWindow.isVertical ? Qt.AlignHCenter : Qt.AlignVCenter
                            Layout.preferredWidth: item ? item.implicitWidth : 0
                            Layout.preferredHeight: item ? item.implicitHeight : 0
                            sourceComponent: BarWidgets.definitionForId(modelData) ? (barBase.widgetComponents[modelData] ?? null) : null
                        }

                    }

                }

                Behavior on width {
                    StdAnim {
                    }

                }

                Behavior on height {
                    StdAnim {
                    }

                }

                Behavior on color {
                    StdAnim {
                    }

                }

            }

            component StdAnim: PropertyAnimation {
                duration: Config.settings.animationSpeed
                easing.type: Easing.InSine
            }

            mask: Region {
                item: barBase
            }

        }

    }

}
