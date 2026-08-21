import QtQuick
import QtQuick.Layouts
import qs.core
import qs.features.settings

Item {
    id: root

    property string currentPosition: Config.barPosition

    Layout.fillWidth: true
    implicitHeight: contentCol.implicitHeight
    Layout.preferredHeight: contentCol.implicitHeight

    ColumnLayout {
        id: contentCol

        width: parent.width
        spacing: Styling.spacing.sm

        // Icon + Title on top, Subtitle below spanning full width
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Styling.spacing.xs

            RowLayout {
                spacing: Styling.spacing.md

                Text {
                    text: "dock_to_bottom"
                    font.family: Config.settings.iconFont
                    font.pixelSize: 20
                    color: Qt.alpha(Colours.palette.on_surface, 0.9)
                }

                Text {
                    text: "Bar position"
                    font.family: Config.settings.font
                    font.pixelSize: Styling.fontSize.title
                    font.weight: Font.Bold
                    color: Qt.alpha(Colours.palette.on_surface, 0.9)
                }

            }

            Text {
                Layout.fillWidth: true
                text: "It always opens towards the centre."
                font.family: Config.settings.font
                font.pixelSize: Styling.fontSize.body
                color: Qt.alpha(Colours.palette.on_surface_variant, 0.75)
            }

        }

        // Position Cards (Above, Below, Left, Right)
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: Styling.spacing.xs
            spacing: Styling.spacing.md

            PositionCard {
                posKey: "top"
                posLabel: "Above"
            }

            PositionCard {
                posKey: "bottom"
                posLabel: "Below"
            }

            PositionCard {
                posKey: "left"
                posLabel: "Left"
            }

            PositionCard {
                posKey: "right"
                posLabel: "Right"
            }

            component PositionCard: StyledRect {
                id: pCard

                property string posKey: "top"
                property string posLabel: "Above"
                property bool isSelected: root.currentPosition === posKey
                property bool hovered: false

                variant: "internalbg"
                useDefaultRadius: true
                Layout.fillWidth: true
                Layout.preferredHeight: 96
                color: hovered ? Colours.palette.surface_container_high : Colours.palette.surface_container_low
                border.color: isSelected ? Colours.palette.primary : (hovered ? Colours.palette.outline : Qt.alpha(Colours.palette.outline, 0.2))
                border.width: isSelected ? 2 : 1

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    // Monitor Illustration (Screen + Stand)
                    Item {
                        Layout.alignment: Qt.AlignHCenter
                        width: 56
                        height: 40

                        // Monitor Screen Body
                        Rectangle {
                            id: screenBody

                            width: 56
                            height: 32
                            radius: 5
                            color: Colours.palette.surface_container_lowest
                            border.color: pCard.isSelected ? Colours.palette.primary : Colours.palette.outline_variant
                            border.width: 1

                            // Bar Indicator Strip inside Screen
                            Rectangle {
                                radius: 1.5
                                color: pCard.isSelected ? Colours.palette.primary : Colours.palette.on_surface
                                width: (pCard.posKey === "left" || pCard.posKey === "right") ? 3 : 28
                                height: (pCard.posKey === "top" || pCard.posKey === "bottom") ? 3 : 18
                                anchors.top: pCard.posKey === "top" ? parent.top : undefined
                                anchors.bottom: pCard.posKey === "bottom" ? parent.bottom : undefined
                                anchors.left: pCard.posKey === "left" ? parent.left : undefined
                                anchors.right: pCard.posKey === "right" ? parent.right : undefined
                                anchors.horizontalCenter: (pCard.posKey === "top" || pCard.posKey === "bottom") ? parent.horizontalCenter : undefined
                                anchors.verticalCenter: (pCard.posKey === "left" || pCard.posKey === "right") ? parent.verticalCenter : undefined
                                anchors.margins: 3
                            }

                        }

                        // Monitor Stand Stem
                        Rectangle {
                            id: stem

                            width: 6
                            height: 5
                            radius: 1
                            color: pCard.isSelected ? Colours.palette.primary : Colours.palette.outline_variant
                            anchors.top: screenBody.bottom
                            anchors.horizontalCenter: screenBody.horizontalCenter
                        }

                        // Monitor Stand Base
                        Rectangle {
                            width: 24
                            height: 2.5
                            radius: 1
                            color: pCard.isSelected ? Colours.palette.primary : Colours.palette.outline_variant
                            anchors.top: stem.bottom
                            anchors.horizontalCenter: screenBody.horizontalCenter
                        }

                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: pCard.posLabel
                        font.family: Config.settings.font
                        font.pixelSize: Styling.fontSize.sm
                        font.weight: pCard.isSelected ? Font.Bold : Font.Medium
                        color: pCard.isSelected ? Colours.palette.primary : Colours.palette.on_surface
                    }

                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: pCard.hovered = true
                    onExited: pCard.hovered = false
                    onClicked: Config.updateKey("bar.position", pCard.posKey)
                }

                Behavior on color {
                    PropertyAnimation {
                        duration: 150
                    }

                }

            }

        }

    }

}
