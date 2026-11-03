import QtQuick
import QtQuick.Layouts
import qs.core

StyledRect {
    id: root

    property string label: ""
    property string resolution: ""
    property string details: ""
    property bool selected: false
    property bool target: false
    property bool allDisplays: false
    property bool hovered: false
    property bool invalid: false
    readonly property bool monitorCard: true
    readonly property real contentScale: Math.max(0.5, Math.min(1, width / 172, height / 102))

    variant: "internalbg"
    useDefaultRadius: true
    implicitWidth: 172
    implicitHeight: 102
    color: Colours.palette.surface_container_low
    border.width: selected ? 2 : 1
    border.color: invalid ? Colours.palette.error
        : selected ? Colours.palette.primary
        : hovered ? Colours.palette.outline
        : Colours.palette.outline_variant

    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(root.width - 8, 160)
        spacing: 4

        Item {
            objectName: "monitorGlyph"
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 56 * root.contentScale
            implicitHeight: 36 * root.contentScale

            Item {
                width: 56
                height: 36
                anchors.centerIn: parent
                scale: root.contentScale
                transformOrigin: Item.Center

                Item {
                    anchors.fill: parent
                    visible: root.allDisplays

                    StyledRect {
                        width: 32
                        height: 22
                        radius: 4
                        useDefaultRadius: false
                        x: 4
                        y: 4
                        color: Colours.palette.surface_container_lowest
                        border.color: root.selected ? Colours.palette.primary : Colours.palette.outline_variant
                        border.width: 1
                    }

                    StyledRect {
                        width: 32
                        height: 22
                        radius: 4
                        useDefaultRadius: false
                        x: 20
                        y: 8
                        color: root.target ? Colours.palette.primary_container : Colours.palette.surface_container_low
                        border.color: root.selected ? Colours.palette.primary : Colours.palette.outline_variant
                        border.width: 1
                    }
                }

                Item {
                    anchors.fill: parent
                    visible: !root.allDisplays

                    StyledRect {
                        id: screenBody
                        width: 52
                        height: 26
                        radius: 4
                        useDefaultRadius: false
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: root.target ? Colours.palette.surface_container_high : Colours.palette.surface_container_lowest
                        border.color: root.selected ? Colours.palette.primary : Colours.palette.outline_variant
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            width: parent.width - 4
                            text: root.label
                            font.family: Config.settings.font
                            font.pixelSize: Styling.fontSize.caption
                            font.weight: Font.Bold
                            color: root.selected ? Colours.palette.primary : Colours.palette.on_surface_variant
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    StyledRect {
                        width: 6
                        height: 4
                        radius: 1
                        useDefaultRadius: false
                        color: root.selected ? Colours.palette.primary : Colours.palette.outline_variant
                        anchors.top: screenBody.bottom
                        anchors.horizontalCenter: screenBody.horizontalCenter
                    }

                    StyledRect {
                        width: 22
                        height: 2
                        radius: 1
                        useDefaultRadius: false
                        color: root.selected ? Colours.palette.primary : Colours.palette.outline_variant
                        anchors.top: screenBody.bottom
                        anchors.topMargin: 4
                        anchors.horizontalCenter: screenBody.horizontalCenter
                    }
                }
            }
        }

        Text {
            Layout.fillWidth: true
            text: root.label
            font.family: Config.settings.font
            font.pixelSize: Styling.fontSize.sm
            font.weight: root.selected ? Font.Bold : Font.Medium
            color: Colours.palette.on_surface
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true
            visible: text.length > 0
            text: root.resolution
            font.family: Config.settings.font
            font.pixelSize: Styling.fontSize.xs
            color: Colours.palette.on_surface_variant
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true
            visible: text.length > 0
            text: root.details
            font.family: Config.settings.font
            font.pixelSize: Styling.fontSize.xs
            color: Colours.palette.on_surface_variant
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
    }

    Behavior on border.color {
        PropertyAnimation {
            duration: Config.settings.animationSpeed ?? 150
            easing.type: Easing.OutQuad
        }
    }

    Accessible.role: Accessible.ListItem
    Accessible.name: label + (resolution.length > 0 ? " " + resolution : "")
}
