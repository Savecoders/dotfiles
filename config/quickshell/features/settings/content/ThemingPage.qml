import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.core
import qs.features
import qs.features.common
import qs.features.settings
import qs.features.settings.content
import qs.features.settings.content.generics
import qs.services

Rectangle {
    id: root

    property string searchQuery: ""
    property var filteredWallpapers: filterWallpapers(Wallpaper.wallpapersList || [], searchQuery)

    function isValidPath(path) {
        return path && path !== "null" && path !== "undefined" && path.length > 0;
    }

    function filterWallpapers(list, query) {
        if (!list)
            return [];

        if (!query || query.trim() === "")
            return list;

        let q = query.toLowerCase().trim();
        return list.filter((path) => {
            let fileName = path.split('/').pop().toLowerCase();
            return fileName.indexOf(q) !== -1;
        });
    }

    color: "transparent"
    Component.onCompleted: {
        if (!Wallpaper.wallpapersList || Wallpaper.wallpapersList.length === 0)
            Wallpaper.reloadWallpapers();

    }

    Rectangle {
        id: pageWrapper

        width: parent.width - 30
        height: parent.height - 60
        anchors.top: parent.top
        anchors.topMargin: (parent.height / 2) - (height / 2)
        anchors.left: parent.left
        anchors.leftMargin: (parent.width / 2) - (width / 2)
        color: "transparent"

        ScrollView {
            anchors.fill: parent
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                width: pageWrapper.width
                spacing: 15

                GenericTitle {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    Layout.preferredHeight: 20
                    text: "Wallpaper"
                    iconCode: "wallpaper"
                }

                GenericSeperator {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.topMargin: 5
                    Layout.preferredWidth: pageWrapper.width
                    Layout.preferredHeight: 3
                }

                RowLayout {
                    Layout.preferredWidth: pageWrapper.width
                    Layout.preferredHeight: pageWrapper.width / 2
                    spacing: 10

                    ClippingWrapperRectangle {
                        color: Colours.palette.surface_container
                        radius: Config.settings.borderRadius
                        Layout.preferredWidth: {
                            if (Config.settings.currentWallpaper === Config.settings.previousWallpaper && Config.settings.currentWallpaper === Config.settings.secondPreviousWallpaper)
                                return pageWrapper.width;
                            else
                                return pageWrapper.width - ((pageWrapper.width / 4) + 10);
                        }
                        Layout.preferredHeight: pageWrapper.width / 2

                        Image {
                            id: background

                            source: Config.settings.currentWallpaper ? Config.settings.currentWallpaper : ""
                            sourceSize.width: 800
                            sourceSize.height: 450
                            fillMode: Image.PreserveAspectCrop

                            MultiEffect {
                                id: darkenEffect

                                source: background
                                anchors.fill: background
                                opacity: Config.settings.desktop.dimDesktopWallpaper ? 1 : 0
                                brightness: -0.1

                                Behavior on opacity {
                                    PropertyAnimation {
                                        duration: Config.settings.animationSpeed
                                        easing.type: Easing.InSine
                                    }

                                }

                            }

                        }

                        Behavior on Layout.preferredWidth {
                            PropertyAnimation {
                                duration: Config.settings.animationSpeed
                                easing.type: Easing.InSine
                            }

                        }

                    }

                    ColumnLayout {
                        Layout.preferredWidth: pageWrapper.width / 4
                        Layout.preferredHeight: pageWrapper.width / 2
                        spacing: 8

                        ClippingWrapperRectangle {
                            color: Colours.palette.surface_container
                            radius: Config.settings.borderRadius
                            Layout.preferredWidth: pageWrapper.width / 4
                            Layout.preferredHeight: {
                                if (Config.settings.previousWallpaper === Config.settings.secondPreviousWallpaper)
                                    return pageWrapper.width / 2;
                                else
                                    return (pageWrapper.width / 4) - 5;
                            }

                            Image {
                                source: isValidPath(Config.settings.previousWallpaper) ? Config.settings.previousWallpaper : ""
                                sourceSize.width: 400
                                sourceSize.height: 225
                                fillMode: Image.PreserveAspectCrop
                                visible: source !== ""

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Wallpaper.setNewWallpaper(Config.settings.previousWallpaper)
                                }

                            }

                            Behavior on Layout.preferredHeight {
                                PropertyAnimation {
                                    duration: Config.settings.animationSpeed
                                    easing.type: Easing.InSine
                                }

                            }

                        }

                        ClippingWrapperRectangle {
                            color: Colours.palette.surface_container
                            radius: Config.settings.borderRadius
                            Layout.preferredWidth: pageWrapper.width / 4
                            Layout.preferredHeight: (pageWrapper.width / 4) - 5
                            opacity: Config.settings.previousWallpaper === Config.settings.secondPreviousWallpaper ? 0 : 1

                            Image {
                                source: isValidPath(Config.settings.secondPreviousWallpaper) ? Config.settings.secondPreviousWallpaper : ""
                                sourceSize.width: 400
                                sourceSize.height: 225
                                fillMode: Image.PreserveAspectCrop
                                visible: source !== ""

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Wallpaper.setNewWallpaper(Config.settings.secondPreviousWallpaper)
                                }

                            }

                            Behavior on opacity {
                                PropertyAnimation {
                                    duration: Config.settings.animationSpeed
                                }

                            }

                        }

                    }

                }

                RowLayout {
                    Layout.preferredWidth: pageWrapper.width
                    Layout.topMargin: 10
                    spacing: 10

                    Rectangle {
                        id: randomBtn

                        property bool hovered: false

                        implicitWidth: randomRow.implicitWidth + 24
                        implicitHeight: 32
                        radius: Math.max(4, Config.settings.borderRadius - 12)
                        color: randomBtn.hovered ? Colours.palette.surface_container_high : Colours.palette.surface_container
                        border.color: Qt.alpha(Colours.palette.outline, 0.3)
                        border.width: 1

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
                            spacing: 6

                            Text {
                                text: "casino"
                                font.family: Config.settings.iconFont
                                font.pixelSize: 16
                                color: Colours.palette.primary
                            }

                            Text {
                                text: "Random Wallpaper"
                                font.family: Config.settings.font
                                font.pixelSize: 12
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

                    Item {
                        Layout.fillWidth: true
                    }

                    // Whisker-style Search Input Field
                    Rectangle {
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 32
                        radius: Math.max(4, Config.settings.borderRadius - 12)
                        color: Colours.palette.surface_container
                        border.color: searchInput.activeFocus ? Colours.palette.primary : Qt.alpha(Colours.palette.outline, 0.3)
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 6

                            Text {
                                text: "search"
                                font.family: Config.settings.iconFont
                                font.pixelSize: 14
                                color: Qt.alpha(Colours.palette.on_surface, 0.6)
                            }

                            TextInput {
                                id: searchInput

                                Layout.fillWidth: true
                                text: root.searchQuery
                                font.family: Config.settings.font
                                font.pixelSize: 12
                                color: Colours.palette.on_surface
                                selectByMouse: true
                                onTextChanged: {
                                    root.searchQuery = text;
                                }

                                Text {
                                    text: "Search wallpapers..."
                                    font.family: Config.settings.font
                                    font.pixelSize: 12
                                    color: Qt.alpha(Colours.palette.on_surface, 0.4)
                                    visible: searchInput.text === "" && !searchInput.activeFocus
                                }

                            }

                            Text {
                                text: "close"
                                font.family: Config.settings.iconFont
                                font.pixelSize: 14
                                color: Qt.alpha(Colours.palette.on_surface, 0.6)
                                visible: searchInput.text !== ""

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: searchInput.text = ""
                                }

                            }

                        }

                        Behavior on border.color {
                            ColorAnimation {
                                duration: Config.settings.animationSpeed
                            }

                        }

                    }

                    Text {
                        text: root.filteredWallpapers.length + " / " + (Wallpaper.wallpapersList ? Wallpaper.wallpapersList.length : 0) + " wallpapers"
                        font.family: Config.settings.font
                        font.pixelSize: 11
                        color: Colours.palette.on_surface_variant
                    }

                }

                ListView {
                    id: wallpaperGallery

                    Layout.preferredWidth: pageWrapper.width
                    Layout.preferredHeight: 90
                    Layout.topMargin: 5
                    orientation: ListView.Horizontal
                    spacing: 10
                    clip: true
                    cacheBuffer: 300
                    model: root.filteredWallpapers

                    Text {
                        anchors.centerIn: parent
                        visible: !Wallpaper.wallpapersList || Wallpaper.wallpapersList.length === 0
                        text: "No wallpapers found in ~/Pictures/Wallpapers"
                        font.family: Config.settings.font
                        font.pixelSize: 12
                        color: Colours.palette.on_surface_variant
                    }

                    delegate: Rectangle {
                        id: galleryCard

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
                            sourceSize.width: 280
                            sourceSize.height: 180
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true

                            Rectangle {
                                anchors.fill: parent
                                radius: galleryCard.radius - 2
                                color: galleryCard.isHovered ? Qt.alpha(Colours.palette.on_surface, 0.1) : "transparent"
                            }

                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: galleryCard.isHovered = true
                            onExited: galleryCard.isHovered = false
                            onClicked: Wallpaper.setNewWallpaper(modelData)
                        }

                        Behavior on border.color {
                            ColorAnimation {
                                duration: Config.settings.animationSpeed
                            }

                        }

                    }

                }

                GenericTitle {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    Layout.preferredHeight: 20
                    Layout.topMargin: 10
                    text: "Style"
                    iconCode: "brush"
                }

                GenericSeperator {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.topMargin: 5
                    Layout.preferredWidth: pageWrapper.width
                    Layout.preferredHeight: 3
                }

                GenericNumberOption {
                    message: "Border radius"
                    value: Config.settings.borderRadius
                    maxValue: 30
                    minValue: 5
                    amountIncrease: () => {
                        if (Config.settings.borderRadius < 30) {
                            Config.settings.borderRadius += 1;
                            Config.updateKey("borderRadius", Config.settings.borderRadius);
                        }
                    }
                    amountDecrease: () => {
                        if (Config.settings.borderRadius > 5) {
                            Config.settings.borderRadius -= 1;
                            Config.updateKey("borderRadius", Config.settings.borderRadius);
                        }
                    }
                    withIcon: true
                    iconCode: "rounded_corner"
                }

                GenericNumberOption {
                    message: "Animation duration (ms)"
                    value: Config.settings.animationSpeed
                    maxValue: 1000
                    minValue: 50
                    amountIncrease: () => {
                        if (Config.settings.animationSpeed < 1000) {
                            Config.settings.animationSpeed += 25;
                            Config.updateKey("animationSpeed", Config.settings.animationSpeed);
                        }
                    }
                    amountDecrease: () => {
                        if (Config.settings.animationSpeed > 50) {
                            Config.settings.animationSpeed -= 25;
                            Config.updateKey("animationSpeed", Config.settings.animationSpeed);
                        }
                    }
                    withIcon: true
                    iconCode: "speed"
                }

                GenericTitle {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    Layout.preferredHeight: 20
                    Layout.topMargin: 10
                    text: "Colours"
                    iconCode: "colors"
                }

                GenericSeperator {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.topMargin: 5
                    Layout.preferredWidth: pageWrapper.width
                    Layout.preferredHeight: 3
                }

                GenericToggleOption {
                    message: "Enable color schemes"
                    option: Config.settings.colours.enableScheme !== false
                    toRun: () => {
                        Config.settings.colours.enableScheme = !Config.settings.colours.enableScheme;
                        Config.updateKey("colours.enableScheme", Config.settings.colours.enableScheme);
                        Wallpaper.changeColourProp();
                        return Config.settings.colours.enableScheme;
                    }
                    withIcon: true
                    iconCode: "tune"
                }

                GenericSelectOption {
                    visible: Config.settings.colours.enableScheme !== false
                    message: "Matugen color scheme"
                    options: ["scheme-tonal-spot", "scheme-expressive", "scheme-vibrant", "scheme-fruit-salad", "scheme-rainbow", "scheme-monochrome", "scheme-fidelity", "scheme-content"]
                    currentIndex: {
                        let idx = options.indexOf(Config.settings.colours.genType);
                        return idx >= 0 ? idx : 0;
                    }
                    toRun: (index) => {
                        let selected = options[index];
                        Config.settings.colours.genType = selected;
                        Config.updateKey("colours.genType", selected);
                        Wallpaper.changeColourProp();
                    }
                    withIcon: true
                    iconCode: "palette"
                }

                GenericToggleOption {
                    message: "Use dark mode"
                    option: Config.settings.colours.mode === "dark"
                    toRun: () => {
                        let nextMode = (Config.settings.colours.mode === "dark") ? "light" : "dark";
                        Config.settings.colours.mode = nextMode;
                        Config.updateKey("colours.mode", nextMode);
                        Wallpaper.changeColourProp();
                        return nextMode === "dark";
                    }
                    withIcon: true
                    iconCode: "dark_mode"
                }

                GenericToggleOption {
                    message: "Use custom colours (overrides generated colours for widgets)"
                    option: Config.settings.colours.useCustom
                    toRun: () => {
                        Config.settings.colours.useCustom = !Config.settings.colours.useCustom;
                        Config.updateKey("colours.useCustom", Config.settings.colours.useCustom);
                        return Config.settings.colours.useCustom;
                    }
                    withIcon: true
                    iconCode: "category"
                }

            }

        }

    }

}
