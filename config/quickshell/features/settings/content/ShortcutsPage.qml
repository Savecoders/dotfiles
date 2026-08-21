import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.core
import qs.features.settings.content.generics

Item {
    id: root

    readonly property var leftCategories: [{
        "title": "PILL",
        "items": [{
            "keys": "SUPER + Space",
            "desc": "App launcher"
        }, {
            "keys": "SUPER + Tab",
            "desc": "Workspace overview"
        }, {
            "keys": "SUPER + Z",
            "desc": "Quick settings"
        }, {
            "keys": "SUPER + I",
            "desc": "These settings"
        }, {
            "keys": "SUPER + /",
            "desc": "Shortcuts cheat sheet"
        }, {
            "keys": "SUPER + SHIFT + W",
            "desc": "Network list"
        }, {
            "keys": "SUPER + SHIFT + B",
            "desc": "Bluetooth"
        }, {
            "keys": "SUPER + V",
            "desc": "Clipboard"
        }, {
            "keys": "CTRL + ALT + Del",
            "desc": "Power menu"
        }, {
            "keys": "SUPER + P",
            "desc": "Screen recording"
        }, {
            "keys": "SUPER + SHIFT + N",
            "desc": "Notifications"
        }, {
            "keys": "SUPER + E",
            "desc": "File manager"
        }]
    }, {
        "title": "APPLICATIONS",
        "items": [{
            "keys": "SUPER + Return",
            "desc": "Terminal"
        }, {
            "keys": "SUPER + T",
            "desc": "Terminal (alt)"
        }, {
            "keys": "SUPER + B",
            "desc": "Browser"
        }, {
            "keys": "SUPER + SHIFT + E",
            "desc": "Files (TUI)"
        }, {
            "keys": "SUPER + O",
            "desc": "Notes"
        }, {
            "keys": "Print",
            "desc": "Screenshot"
        }, {
            "keys": "SUPER + SHIFT + T",
            "desc": "OCR text capture"
        }]
    }, {
        "title": "SYSTEM",
        "items": [{
            "keys": "SUPER + SHIFT + F12",
            "desc": "Turn screen off"
        }, {
            "keys": "SUPER + M",
            "desc": "Exit Hyprland"
        }]
    }]
    readonly property var rightCategories: [{
        "title": "WINDOWS",
        "items": [{
            "keys": "SUPER + C",
            "desc": "Close window"
        }, {
            "keys": "SUPER + SHIFT + F",
            "desc": "Fullscreen"
        }, {
            "keys": "SUPER + V",
            "desc": "Floating window"
        }, {
            "keys": "SUPER + SHIFT + Space",
            "desc": "Float & centre"
        }, {
            "keys": "SUPER + J",
            "desc": "Toggle split"
        }]
    }, {
        "title": "WORKSPACES",
        "items": [{
            "keys": "SUPER + Space",
            "desc": "Empty workspace"
        }, {
            "keys": "SUPER + S",
            "desc": "Special workspace (Scratchpad)"
        }, {
            "keys": "SUPER + SHIFT + A",
            "desc": "Pack workspaces"
        }]
    }, {
        "title": "FIXED",
        "items": [{
            "keys": "Super + 1..0",
            "desc": "Switch workspace"
        }, {
            "keys": "Super + Shift + 1..0",
            "desc": "Move to workspace"
        }, {
            "keys": "Super + Left / Right",
            "desc": "Focus by direction"
        }, {
            "keys": "Super + Up / Down",
            "desc": "Move window"
        }, {
            "keys": "Alt + Left / Right",
            "desc": "Resize window"
        }, {
            "keys": "Super + Wheel",
            "desc": "Cycle workspaces"
        }, {
            "keys": "Super + LMB + Drag",
            "desc": "Drag window"
        }, {
            "keys": "Super + RMB + Drag",
            "desc": "Resize window"
        }, {
            "keys": "Media keys",
            "desc": "Volume & brightness"
        }]
    }]

    Item {
        id: pageWrapper

        width: parent.width - 30
        height: parent.height - 60
        anchors.top: parent.top
        anchors.topMargin: (parent.height / 2) - (height / 2)
        anchors.left: parent.left
        anchors.leftMargin: (parent.width / 2) - (width / 2)

        ScrollView {
            anchors.fill: parent
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                width: pageWrapper.width - 20
                spacing: Styling.spacing.sm

                GenericTitle {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    Layout.preferredHeight: 20
                    Layout.topMargin: 10
                    text: "Shortcuts"
                    iconCode: "keyboard"
                }

                GenericSeperator {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.topMargin: 5
                    Layout.preferredWidth: pageWrapper.width
                    Layout.preferredHeight: 3
                }

                Text {
                    text: "Click a shortcut to change it. ✕ removes it."
                    font.family: Config.settings.font
                    font.pixelSize: Styling.fontSize.sm
                    color: Qt.alpha(Colours.palette.on_surface_variant, 0.7)
                    Layout.topMargin: 2
                    Layout.bottomMargin: 8
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    spacing: Styling.spacing.section

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        Layout.preferredWidth: 1
                        spacing: Styling.spacing.md

                        Repeater {
                            model: root.leftCategories

                            ColumnLayout {
                                id: leftSection

                                required property var modelData

                                Layout.fillWidth: true
                                spacing: Styling.spacing.xs

                                Text {
                                    text: leftSection.modelData.title
                                    font.family: Config.settings.font
                                    font.pixelSize: Styling.fontSize.sm
                                    font.weight: Font.Bold
                                    color: Colours.palette.primary
                                    Layout.topMargin: 8
                                    Layout.bottomMargin: 2
                                }

                                Repeater {
                                    model: leftSection.modelData.items

                                    RowLayout {
                                        id: sRow

                                        required property var modelData

                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 34
                                        spacing: Styling.spacing.md

                                        // Key Combo Pill
                                        StyledRect {
                                            id: comboPill

                                            property bool hovered: false

                                            variant: "internalbg"
                                            useDefaultRadius: false
                                            Layout.preferredWidth: 172
                                            Layout.preferredHeight: 32
                                            radius: Styling.radius.sm
                                            color: hovered ? Colours.palette.surface_container_highest : Colours.palette.surface_container
                                            border.color: Qt.alpha(Colours.palette.outline, 0.25)
                                            border.width: 1

                                            Text {
                                                anchors.centerIn: parent
                                                text: sRow.modelData.keys
                                                font.family: Config.settings.font
                                                font.pixelSize: Styling.fontSize.body
                                                font.weight: Font.Bold
                                                color: Colours.palette.on_surface
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onEntered: comboPill.hovered = true
                                                onExited: comboPill.hovered = false
                                            }

                                        }

                                        // Description
                                        Text {
                                            Layout.fillWidth: true
                                            text: sRow.modelData.desc
                                            font.family: Config.settings.font
                                            font.pixelSize: Styling.fontSize.body
                                            color: Colours.palette.on_surface
                                            elide: Text.ElideRight
                                        }

                                    }

                                }

                            }

                        }

                    }

                    // Right Column
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        Layout.preferredWidth: 1
                        spacing: Styling.spacing.md

                        Repeater {
                            model: root.rightCategories

                            ColumnLayout {
                                id: rightSection

                                required property var modelData

                                Layout.fillWidth: true
                                spacing: Styling.spacing.xs

                                Text {
                                    text: rightSection.modelData.title
                                    font.family: Config.settings.font
                                    font.pixelSize: Styling.fontSize.sm
                                    font.weight: Font.Bold
                                    color: Colours.palette.primary
                                    Layout.topMargin: 8
                                    Layout.bottomMargin: 2
                                }

                                Repeater {
                                    model: rightSection.modelData.items

                                    RowLayout {
                                        id: rRow

                                        required property var modelData

                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 34
                                        spacing: Styling.spacing.md

                                        // Key Combo Pill
                                        StyledRect {
                                            id: rComboPill

                                            property bool hovered: false

                                            variant: "internalbg"
                                            useDefaultRadius: false
                                            Layout.preferredWidth: 172
                                            Layout.preferredHeight: 32
                                            radius: Styling.radius.sm
                                            color: hovered ? Colours.palette.surface_container_highest : Colours.palette.surface_container
                                            border.color: Qt.alpha(Colours.palette.outline, 0.25)
                                            border.width: 1

                                            Text {
                                                anchors.centerIn: parent
                                                text: rRow.modelData.keys
                                                font.family: Config.settings.font
                                                font.pixelSize: Styling.fontSize.body
                                                font.weight: Font.Bold
                                                color: Colours.palette.on_surface
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onEntered: rComboPill.hovered = true
                                                onExited: rComboPill.hovered = false
                                            }

                                        }

                                        // Description
                                        Text {
                                            Layout.fillWidth: true
                                            text: rRow.modelData.desc
                                            font.family: Config.settings.font
                                            font.pixelSize: Styling.fontSize.body
                                            color: Colours.palette.on_surface
                                            elide: Text.ElideRight
                                        }

                                    }

                                }

                            }

                        }

                    }

                }

            }

        }

    }

}
