import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.core
import qs.features
import qs.services

Loader {
    id: root

    required property bool isOpen
    property real anchorX: 0
    property real anchorY: 0
    property real anchorWidth: 0
    property real anchorHeight: 0
    property var targetScreen: null
    property real cardWidth: 290
    property real contentMargin: 16
    readonly property real screenMargin: 20
    readonly property real fallbackScreenWidth: 1920
    readonly property real fallbackScreenHeight: 1080
    readonly property real edgeFallbackOffset: 48
    readonly property real barMargin: Config.get("bar.margin", 8)
    readonly property real barClearance: 12 + barMargin
    readonly property string barPos: Config.barPosition
    property int viewYear: (new Date()).getFullYear()
    property int viewMonth: (new Date()).getMonth()
    readonly property var monthNames: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    readonly property var dayHeaders: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
    readonly property var todayDate: new Date()
    readonly property int todayDay: todayDate.getDate()
    readonly property int todayMonth: todayDate.getMonth()
    readonly property int todayYear: todayDate.getFullYear()

    signal dismissed()

    function resetToToday() {
        let now = new Date();
        root.viewYear = now.getFullYear();
        root.viewMonth = now.getMonth();
    }

    function prevMonth() {
        if (root.viewMonth === 0) {
            root.viewYear -= 1;
            root.viewMonth = 11;
        } else {
            root.viewMonth -= 1;
        }
    }

    function nextMonth() {
        if (root.viewMonth === 11) {
            root.viewYear += 1;
            root.viewMonth = 0;
        } else {
            root.viewMonth += 1;
        }
    }

    function generateCalendarCells(y, m) {
        let daysInMonth = new Date(y, m + 1, 0).getDate();
        let firstDayIndex = new Date(y, m, 1).getDay();
        let startOffset = (firstDayIndex + 6) % 7;
        let daysInPrevMonth = new Date(y, m, 0).getDate();
        let cells = [];
        for (let i = startOffset - 1; i >= 0; i--) {
            cells.push({
                "day": daysInPrevMonth - i,
                "isCurrentMonth": false
            });
        }
        for (let d = 1; d <= daysInMonth; d++) {
            cells.push({
                "day": d,
                "isCurrentMonth": true
            });
        }
        let remaining = (7 - (cells.length % 7)) % 7;
        for (let d = 1; d <= remaining; d++) {
            cells.push({
                "day": d,
                "isCurrentMonth": false
            });
        }
        return cells;
    }

    active: false
    onIsOpenChanged: {
        if (root.isOpen) {
            root.resetToToday();
            deactivateTimer.stop();
            root.active = true;
        } else {
            deactivateTimer.restart();
        }
    }

    Timer {
        id: deactivateTimer

        interval: Config.get("animationSpeed", 150) + 50
        repeat: false
        onTriggered: {
            if (!root.isOpen)
                root.active = false;

        }
    }

    sourceComponent: PanelWindow {
        id: popupWin

        readonly property real screenWidth: popupWin.screen ? popupWin.screen.width : root.fallbackScreenWidth
        readonly property real screenHeight: popupWin.screen ? popupWin.screen.height : root.fallbackScreenHeight

        screen: root.targetScreen ? root.targetScreen : Quickshell.screens[0]
        aboveWindows: true
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: root.isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        focusable: root.isOpen
        visible: root.isOpen

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        MouseArea {
            anchors.fill: parent
            focus: root.isOpen
            Keys.onEscapePressed: {
                root.dismissed();
            }
            onClicked: {
                root.dismissed();
            }
        }

        StyledRect {
            id: card

            variant: "popup"
            useDefaultRadius: true
            width: root.cardWidth
            height: cardContentCol.implicitHeight + (root.contentMargin * 2)
            color: Transparency.colorFor(variant)
            border.color: Colours.palette.outline_variant
            border.width: 1
            opacity: root.isOpen ? 1 : 0
            scale: root.isOpen ? 1 : 0.94
            x: {
                if (root.barPos === "left") {
                    let leftX = root.anchorWidth > 0 ? (root.anchorX + root.anchorWidth + root.barClearance) : (root.edgeFallbackOffset + root.screenMargin);
                    return Math.max(root.screenMargin, Math.min(popupWin.screenWidth - width - root.screenMargin, leftX));
                } else if (root.barPos === "right") {
                    let rightX = root.anchorWidth > 0 ? (root.anchorX - width - root.barClearance) : (popupWin.screenWidth - width - root.edgeFallbackOffset);
                    return Math.max(root.screenMargin, Math.min(popupWin.screenWidth - width - root.screenMargin, rightX));
                } else {
                    let targetCenter = root.anchorWidth > 0 ? (root.anchorX + (root.anchorWidth / 2)) : (popupWin.screenWidth / 2);
                    return Math.max(root.screenMargin, Math.min(popupWin.screenWidth - width - root.screenMargin, targetCenter - (width / 2)));
                }
            }
            y: {
                if (root.barPos === "bottom") {
                    let topY = root.anchorHeight > 0 ? (root.anchorY - height - root.barClearance) : (popupWin.screenHeight - height - root.edgeFallbackOffset);
                    return Math.max(root.screenMargin, Math.min(popupWin.screenHeight - height - root.screenMargin, topY));
                } else if (root.barPos === "top") {
                    let bottomY = root.anchorHeight > 0 ? (root.anchorY + root.anchorHeight + root.barClearance) : (root.edgeFallbackOffset + root.screenMargin);
                    return Math.max(root.screenMargin, Math.min(popupWin.screenHeight - height - root.screenMargin, bottomY));
                } else {
                    let targetCenter = root.anchorHeight > 0 ? (root.anchorY + (root.anchorHeight / 2)) : (popupWin.screenHeight / 2);
                    return Math.max(root.screenMargin, Math.min(popupWin.screenHeight - height - root.screenMargin, targetCenter - (height / 2)));
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: (mouse) => {
                    mouse.accepted = true;
                }
            }

            ColumnLayout {
                id: cardContentCol

                anchors.fill: parent
                anchors.margins: root.contentMargin
                spacing: Styling.spacing.md

                // Header: [Month Year] ... [Today] [<] [>]
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Styling.spacing.xs

                    Text {
                        text: root.monthNames[root.viewMonth] + " " + root.viewYear
                        font.family: Config.settings.font
                        font.pixelSize: Styling.fontSize.lg
                        font.weight: Font.Bold
                        color: Colours.palette.on_surface
                        Layout.fillWidth: true
                    }

                    // Return to today button
                    StyledRect {
                        id: todayBtn

                        variant: "internalbg"
                        useDefaultRadius: false
                        radius: Math.max(4, Config.settings.borderRadius - 4)
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        color: todayMouse.containsMouse ? Colours.palette.surface_container_high : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "today"
                            font.family: Config.settings.iconFont
                            font.pixelSize: Styling.fontSize.md
                            color: todayMouse.containsMouse ? Colours.palette.primary : Colours.palette.on_surface_variant
                        }

                        MouseArea {
                            id: todayMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.resetToToday()
                        }

                    }

                    // Prev month
                    StyledRect {
                        id: prevBtn

                        variant: "internalbg"
                        useDefaultRadius: false
                        radius: Math.max(4, Config.settings.borderRadius - 4)
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        color: prevMouse.containsMouse ? Colours.palette.surface_container_high : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "chevron_left"
                            font.family: Config.settings.iconFont
                            font.pixelSize: Styling.fontSize.lg
                            color: prevMouse.containsMouse ? Colours.palette.primary : Colours.palette.on_surface_variant
                        }

                        MouseArea {
                            id: prevMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.prevMonth()
                        }

                    }

                    // Next month
                    StyledRect {
                        id: nextBtn

                        variant: "internalbg"
                        useDefaultRadius: false
                        radius: Math.max(4, Config.settings.borderRadius - 4)
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        color: nextMouse.containsMouse ? Colours.palette.surface_container_high : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "chevron_right"
                            font.family: Config.settings.iconFont
                            font.pixelSize: Styling.fontSize.lg
                            color: nextMouse.containsMouse ? Colours.palette.primary : Colours.palette.on_surface_variant
                        }

                        MouseArea {
                            id: nextMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.nextMonth()
                        }

                    }

                }

                // Days of week header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    Repeater {
                        model: root.dayHeaders

                        Text {
                            Layout.fillWidth: true
                            text: modelData
                            font.family: Config.settings.font
                            font.pixelSize: Styling.fontSize.xs
                            font.weight: Font.DemiBold
                            color: Colours.palette.on_surface_variant
                            horizontalAlignment: Text.AlignHCenter
                        }

                    }

                }

                // Days grid
                GridLayout {
                    id: daysGrid

                    Layout.fillWidth: true
                    columns: 7
                    columnSpacing: 2
                    rowSpacing: 2

                    Repeater {
                        model: root.generateCalendarCells(root.viewYear, root.viewMonth)

                        StyledRect {
                            id: dayCell

                            readonly property bool isToday: modelData.isCurrentMonth && modelData.day === root.todayDay && root.viewMonth === root.todayMonth && root.viewYear === root.todayYear

                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            variant: isToday ? "focus" : "internalbg"
                            useDefaultRadius: false
                            radius: Math.max(4, Config.settings.borderRadius - 4)
                            color: {
                                if (isToday)
                                    return Colours.palette.primary;

                                if (cellMouseArea.containsMouse)
                                    return Colours.palette.surface_container_high;

                                return "transparent";
                            }
                            border.width: isToday ? 0 : 0

                            Text {
                                anchors.centerIn: parent
                                text: String(modelData.day)
                                font.family: Config.settings.font
                                font.pixelSize: Styling.fontSize.sm
                                font.weight: dayCell.isToday ? Font.Bold : Font.Normal
                                color: {
                                    if (dayCell.isToday)
                                        return Colours.palette.on_primary;

                                    if (modelData.isCurrentMonth)
                                        return Colours.palette.on_surface;

                                    return Qt.alpha(Colours.palette.on_surface_variant, 0.35);
                                }
                            }

                            MouseArea {
                                id: cellMouseArea

                                anchors.fill: parent
                                hoverEnabled: true
                            }

                        }

                    }

                }

            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Config.get("animationSpeed", 150)
                    easing.type: Easing.OutQuad
                }

            }

            Behavior on scale {
                NumberAnimation {
                    duration: Config.get("animationSpeed", 150)
                    easing.type: Easing.OutQuad
                }

            }

        }

    }

}
