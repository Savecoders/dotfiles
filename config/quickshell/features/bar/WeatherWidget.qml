import QtQuick
import QtQuick.Layouts
import qs.core
import qs.services

StyledRect {
    id: root

    property bool isVertical: false
    property string tooltipText: {
        let text = "Weather: " + (Weather.desc || "Loading...");
        if (Weather.temp && Weather.temp !== "--")
            text += " (" + Weather.temp + ")";

        if (Weather.location)
            text += " • " + Weather.location;

        if (Weather.feelsLike && Weather.feelsLike !== "--")
            text += "\nFeels like: " + Weather.feelsLike;

        if (Weather.humidity && Weather.humidity !== "--")
            text += " • Humidity: " + Weather.humidity;

        if (Weather.windSpeed && Weather.windSpeed !== "--")
            text += " • Wind: " + Weather.windSpeed;

        return text;
    }

    variant: "transparent"
    color: "transparent"
    implicitWidth: isVertical ? Styling.fontSize.display : (contentLayout.implicitWidth + Styling.spacing.lg)
    implicitHeight: isVertical ? (Styling.fontSize.display + Styling.spacing.sm) : Styling.fontSize.display
    Component.onDestruction: Tooltip.hide()

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: {
            if (root.tooltipText !== "")
                Tooltip.showItem(root, root.tooltipText);

        }
        onExited: Tooltip.hide()
        onClicked: {
            Tooltip.hide();
            Weather.fetchWeather();
        }
    }

    GridLayout {
        id: contentLayout

        anchors.centerIn: parent
        columns: root.isVertical ? 1 : 2
        rows: root.isVertical ? 2 : 1
        columnSpacing: root.isVertical ? Styling.spacing.none : Styling.spacing.sm
        rowSpacing: root.isVertical ? Styling.spacing.xs : Styling.spacing.none

        Text {
            id: iconText

            text: Weather.icon || "partly_cloudy_day"
            font.family: Config.settings.iconFont
            font.pixelSize: root.isVertical ? Styling.fontSize.title : Styling.fontSize.lg
            color: mouseArea.containsMouse ? Colours.palette.primary : Colours.palette.on_surface
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            Behavior on color {
                PropertyAnimation {
                    duration: Config.settings.animationSpeed ?? 150
                    easing.type: Easing.InSine
                }

            }

        }

        Text {
            id: tempText

            text: Weather.temp || "--"
            font.family: Config.get("font", "SF Pro Display")
            font.pixelSize: root.isVertical ? Styling.fontSize.caption : Styling.fontSize.body
            font.weight: 600
            color: mouseArea.containsMouse ? Colours.palette.primary : Colours.palette.on_surface
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            Behavior on color {
                PropertyAnimation {
                    duration: Config.settings.animationSpeed ?? 150
                    easing.type: Easing.InSine
                }

            }

        }

    }

}
