import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.core
import qs.services

Item {
    id: contributionCalendar

    property var contribs: (Github && Github.contributions) ? Github.contributions : []
    readonly property int textSpacing: Styling.spacing.sm

    function contributionColor(level) {
        if (level === 0)
            return Colours.palette.surface_container;

        if (level === 1)
            return Colours.palette.primary_container;

        if (level === 2)
            return Colours.palette.primary;

        if (level === 3)
            return Colours.palette.secondary;

        return Colours.palette.primary;
    }

    Layout.fillWidth: true
    Layout.leftMargin: 20
    Layout.rightMargin: 20
    Layout.topMargin: 20
    implicitHeight: contentThing.implicitHeight
    Layout.preferredHeight: contentThing.implicitHeight

    ColumnLayout {
        id: contentThing

        anchors.fill: parent
        spacing: Styling.spacing.lg

        RowLayout {
            Layout.fillWidth: true
            spacing: Styling.spacing.sm

            StyledRect {
                width: 24
                height: 24
                variant: "internalbg"
                useDefaultRadius: false
                border.width: 0
                color: "transparent"
                radius: Styling.radius.lg
                clip: true

                Image {
                    source: "https://github.com/" + Config.settings.misc.githubUsername + ".png"
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop
                    sourceSize: Qt.size(24, 24)
                    asynchronous: true
                    cache: true
                    onStatusChanged: {
                        if (status === Image.Error)
                            console.warn("[Github] Failed to load avatar image");

                    }
                }

            }

            Item {
                width: Styling.spacing.sm
            }

            Text {
                text: "@" + Config.settings.misc.githubUsername
                font.family: Config.settings.font
                font.pixelSize: Styling.fontSize.label
                color: Colours.palette.on_surface
            }

            Text {
                text: "•"
                font.pixelSize: Styling.fontSize.xs
                color: Colours.palette.outline
            }

            Text {
                text: (Github && Github.contributionNumber !== undefined) ? Github.contributionNumber : "0"
                font.pixelSize: Styling.fontSize.xs
                font.family: Config.settings.font
                color: Colours.palette.primary
            }

            Text {
                text: "contributions in the last year"
                font.pixelSize: Styling.fontSize.xs
                font.family: Config.settings.font
                color: Colours.palette.on_surface_variant
            }

            Item {
                Layout.fillWidth: true
            }

        }

        Canvas {
            id: gridCanvas

            Layout.fillWidth: true
            Layout.preferredHeight: 70
            onWidthChanged: requestPaint()
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                const contribs = contributionCalendar.contribs || [];
                const numDays = 7;
                const gap = 2;
                const approxStep = 10;
                const numWeeks = Math.max(1, Math.floor((width + gap) / approxStep));
                const step = width / numWeeks;
                const cellW = Math.max(1, step - gap);
                const cellH = Math.min(8, Math.floor((height - (numDays - 1) * gap) / numDays));
                for (var week = 0; week < numWeeks; week++) {
                    for (var day = 0; day < numDays; day++) {
                        var idx = week * numDays + day;
                        var level = (contribs[idx] && contribs[idx].level !== undefined) ? contribs[idx].level : 0;
                        ctx.fillStyle = contributionCalendar.contributionColor(level);
                        ctx.fillRect(week * step, day * (cellH + gap), cellW, cellH);
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: (!Github || !Github.loaded || !contributionCalendar.contribs || contributionCalendar.contribs.length === 0 || Github.contributionNumber === 0)
                text: "No se encontraron contribuciones"
                font.family: Config.settings.font
                font.pixelSize: Styling.fontSize.sm
                font.weight: 500
                color: Qt.alpha(Colours.palette.on_surface, 0.7)
            }

            Connections {
                function onContribsChanged() {
                    gridCanvas.requestPaint();
                }

                target: contributionCalendar
            }

            Connections {
                function onColoursChanged() {
                    gridCanvas.requestPaint();
                }

                target: Colours
            }

        }

    }

}
