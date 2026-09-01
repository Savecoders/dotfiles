import QtQuick
import QtQuick.Layouts
import qs.core
import qs.features
import qs.features.common
import qs.features.dashboard.toggles
import qs.services

AnchoredPopup {
    id: root

    required property bool isBatteryOpen

    isOpen: isBatteryOpen
    anchorX: IPCLoader.batteryX
    anchorY: IPCLoader.batteryY
    anchorWidth: IPCLoader.batteryWidth
    anchorHeight: IPCLoader.batteryHeight
    cardWidth: 320
    onDismissed: IPCLoader.isBatteryOpen = false

    cardContent: Component {
        ColumnLayout {
            id: contentCol

            spacing: Styling.spacing.lg

            // Header Section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Styling.spacing.xs

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Styling.spacing.md

                    Text {
                        text: Power.getBatteryIcon()
                        font.family: Config.settings.iconFont
                        font.pixelSize: Styling.fontSize.headline
                        color: Power.charging ? Colours.palette.primary : (Power.percent <= 20 ? Colours.palette.error : Colours.palette.on_surface)
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Text {
                        text: Power.percent + "%" + (Power.charging ? " (Charging)" : "")
                        font.family: Config.settings.font
                        font.pixelSize: Styling.fontSize.lg
                        font.weight: Font.Bold
                        color: Colours.palette.on_surface
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    // Reload Button on Far Right
                    MButton {
                        icon: "refresh"
                        btnVariant: "iconOnly"
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        iconSize: Styling.fontSize.sm
                        onClicked: Power.refreshProfile()
                    }

                }

                Text {
                    Layout.fillWidth: true
                    text: {
                        let prof = "Balanced";
                        if (Power.activeProfile === "power-saver")
                            prof = "Power Saver";
                        else if (Power.activeProfile === "performance")
                            prof = "Performance";
                        return "Active profile: " + prof;
                    }
                    font.family: Config.settings.font
                    font.pixelSize: Styling.fontSize.body
                    color: Qt.alpha(Colours.palette.on_surface_variant, 0.75)
                }

            }

            // Power Profiles: Border-only accent selection using Config.settings.borderRadius
            // TODO: load the profiles in OS actually inject default profile XD
            RowLayout {
                Layout.fillWidth: true
                spacing: Styling.spacing.sm

                ProfileCard {
                    profKey: "power-saver"
                    profLabel: "Power saver"
                    iconCode: "eco"
                }

                ProfileCard {
                    profKey: "balanced"
                    profLabel: "Balanced"
                    iconCode: "speed"
                }

                ProfileCard {
                    profKey: "performance"
                    profLabel: "Performance"
                    iconCode: "bolt"
                }

                component ProfileCard: StyledRect {
                    id: pCard

                    property string profKey: "balanced"
                    property string profLabel: "Balanced"
                    property string iconCode: "speed"
                    readonly property bool isSelected: Power.activeProfile === profKey
                    property bool hovered: mouseArea.containsMouse
                    property bool pressed: mouseArea.pressed

                    variant: "internalbg"
                    useDefaultRadius: true
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    scale: pressed ? 0.98 : 1
                    color: {
                        if (isSelected)
                            return hovered ? Colours.palette.primary_container : Colours.palette.surface_container_high;

                        return hovered ? Colours.palette.surface_container_high : Colours.palette.surface_container_low;
                    }
                    border.color: isSelected ? Colours.palette.primary : (hovered ? Colours.palette.outline : Colours.palette.outline_variant)
                    border.width: isSelected ? 2 : 1

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            text: pCard.iconCode
                            font.family: Config.settings.iconFont
                            font.pixelSize: Styling.fontSize.xl
                            color: pCard.isSelected ? (pCard.hovered ? Colours.palette.on_primary_container : Colours.palette.primary) : (pCard.hovered ? Colours.palette.on_surface : Colours.palette.on_surface_variant)
                            Layout.alignment: Qt.AlignHCenter

                            Behavior on color {
                                PropertyAnimation {
                                    duration: Config.settings.animationSpeed ?? 150
                                    easing.type: Easing.OutQuad
                                }

                            }

                        }

                        Text {
                            text: pCard.profLabel
                            font.family: Config.settings.font
                            font.pixelSize: Styling.fontSize.body
                            font.weight: pCard.isSelected ? Font.Medium : Font.Normal
                            color: pCard.isSelected ? (pCard.hovered ? Colours.palette.on_primary_container : Colours.palette.primary) : (pCard.hovered ? Colours.palette.on_surface : Colours.palette.on_surface_variant)
                            Layout.alignment: Qt.AlignHCenter

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
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Power.setProfile(pCard.profKey)
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

                    Behavior on scale {
                        NumberAnimation {
                            duration: 80
                            easing.type: Easing.OutQuad
                        }

                    }

                }

            }

            // Battery Infor Cards (Capacity, Health, Power rate)
            RowLayout {
                Layout.fillWidth: true
                spacing: Styling.spacing.sm

                MetricCard {
                    title: "Capacity"
                    valueText: Power.capacityWh > 0 ? (Power.capacityWh + " Wh") : "-"
                }

                MetricCard {
                    title: "Health"
                    valueText: Power.healthPercent > 0 ? (Power.healthPercent + "%") : "-"
                }

                MetricCard {
                    title: "Power rate"
                    valueText: Power.powerDrawWatts > 0 ? (Power.powerDrawWatts + " W") : "-"
                }

                component MetricCard: StyledRect {
                    id: mCard

                    property string title: ""
                    property string valueText: ""

                    variant: "internalbg"
                    useDefaultRadius: true
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: Colours.palette.surface_container_low
                    border.color: Colours.palette.outline_variant
                    border.width: 1

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 1

                        Text {
                            text: mCard.title
                            font.family: Config.settings.font
                            font.pixelSize: Styling.fontSize.md
                            color: Colours.palette.on_surface_variant
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text: mCard.valueText
                            font.family: Config.settings.font
                            font.pixelSize: Styling.fontSize.body
                            font.weight: Font.Bold
                            color: Colours.palette.on_surface
                            Layout.alignment: Qt.AlignHCenter
                        }

                    }

                }

            }

        }

    }

}
