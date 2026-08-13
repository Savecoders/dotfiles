import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import qs.core
import qs.services

Item {
    id: root

    Layout.fillWidth: true
    Layout.leftMargin: 15
    Layout.rightMargin: 15
    Layout.preferredHeight: contentColumn.implicitHeight
    implicitHeight: contentColumn.implicitHeight

    ColumnLayout {
        id: contentColumn

        anchors.fill: parent
        spacing: 10

        // Header Row
        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                text: "wallpaper"
                font.family: Config.settings.iconFont
                font.pixelSize: 16
                color: Colours.palette.primary
            }

            Text {
                text: "Wallpapers"
                font.family: Config.settings.font
                font.pixelSize: 13
                font.weight: 600
                color: Colours.palette.on_surface
            }

            Rectangle {
                implicitWidth: badgeText.implicitWidth + 12
                implicitHeight: 18
                radius: 9
                color: Colours.palette.surface_container_highest

                Text {
                    id: badgeText

                    anchors.centerIn: parent
                    text: Wallpaper.wallpapersList.length + " items"
                    font.family: Config.settings.font
                    font.pixelSize: 10
                    font.weight: 500
                    color: Colours.palette.on_surface_variant
                }

            }

            Item {
                Layout.fillWidth: true
            }

            // Random Wallpaper Button
            Rectangle {
                id: randomBtn

                property bool hovered: false

                implicitWidth: randomRow.implicitWidth + 16
                implicitHeight: 26
                radius: 13
                color: randomBtn.hovered ? Colours.palette.surface_container_high : Colours.palette.surface_container

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: randomBtn.hovered = true
                    onExited: randomBtn.hovered = false
                    onClicked: Wallpaper.setRandomWallpaper()
                }

                RowLayout {
                    id: randomRow

                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "casino"
                        font.family: Config.settings.iconFont
                        font.pixelSize: 14
                        color: Colours.palette.primary
                    }

                    Text {
                        text: "Random"
                        font.family: Config.settings.font
                        font.pixelSize: 11
                        font.weight: 600
                        color: Colours.palette.on_surface
                    }

                }

                Behavior on color {
                    PropertyAnimation {
                        duration: Config.settings.animationSpeed
                        easing.type: Easing.InSine
                    }

                }

            }

        }

        // Horizontal Wallpapers Carousel
        ListView {
            id: wallpaperList

            Layout.fillWidth: true
            Layout.preferredHeight: 90
            orientation: ListView.Horizontal
            spacing: 10
            clip: true
            model: Wallpaper.wallpapersList

            Text {
                anchors.centerIn: parent
                visible: Wallpaper.wallpapersList.length === 0
                text: "No wallpapers found in ~/Pictures/Wallpapers"
                font.family: Config.settings.font
                font.pixelSize: 12
                color: Colours.palette.on_surface_variant
            }

            delegate: Rectangle {
                id: card

                property bool isSelected: (Config.settings.currentWallpaper === modelData || Config.settings.wallpaperToSet === modelData)
                property bool isHovered: false

                width: 140
                height: 90
                radius: Math.max(6, Config.settings.borderRadius - 8)
                color: Colours.palette.surface_container
                border.color: isSelected ? Colours.palette.primary : (isHovered ? Colours.palette.outline : "transparent")
                border.width: isSelected ? 2 : 1

                Image {
                    anchors.fill: parent
                    anchors.margins: 2
                    source: "file://" + modelData
                    sourceSize: Qt.size(280, 180)
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true

                    Rectangle {
                        anchors.fill: parent
                        radius: card.radius - 2
                        color: card.isHovered ? Qt.alpha(Colours.palette.on_surface, 0.1) : "transparent"
                    }

                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: card.isHovered = true
                    onExited: card.isHovered = false
                    onClicked: Wallpaper.setNewWallpaper(modelData)
                }

                Behavior on border.color {
                    ColorAnimation {
                        duration: Config.settings.animationSpeed
                    }

                }

            }

        }

    }

}
