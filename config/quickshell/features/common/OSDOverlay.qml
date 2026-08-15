import QtQuick
import QtQuick.Layouts
import qs.core

StyledRect {
    id: root

    property int percent: 10
    property string iconName: "volume_up"
    property string labelText: percent + "%"

    function show() {
        if (fadeOut.running)
            fadeOut.stop();

        fadeIn.start();
        hideTimer.restart();
    }

    variant: "popup"
    width: 144
    height: 144
    color: Colours.palette.surface_container
    radius: Config.settings && Config.settings.borderRadius !== undefined ? Config.settings.borderRadius : 16
    border.color: Qt.alpha(Colours.palette.outline, 0.15)
    border.width: 1
    opacity: 0
    visible: false

    Timer {
        id: hideTimer

        interval: 1800
        onTriggered: fadeOut.start()
    }

    SequentialAnimation {
        id: fadeIn

        PropertyAction {
            target: root
            property: "visible"
            value: true
        }

        NumberAnimation {
            target: root
            property: "opacity"
            to: 1
            duration: (Config.settings && Config.settings.animationSpeed !== undefined) ? (Config.settings.animationSpeed / 2) : 100
        }

    }

    SequentialAnimation {
        id: fadeOut

        NumberAnimation {
            target: root
            property: "opacity"
            to: 0
            duration: (Config.settings && Config.settings.animationSpeed !== undefined) ? Config.settings.animationSpeed : 200
        }

        PropertyAction {
            target: root
            property: "visible"
            value: false
        }

    }

    CircularProgressIcon {
        anchors.centerIn: parent
        implicitWidth: 90
        implicitHeight: 90
        value: Math.max(0, Math.min(100, root.percent)) / 100
        icon: root.iconName
        iconPixelSize: Styling.fontSize.display
        subText: root.labelText
        subTextPixelSize: Styling.fontSize.body
        strokeWidth: 5
        fgColor: Colours.palette.primary
        bgColor: Qt.alpha(Colours.palette.outline, 0.25)
        subTextColor: Colours.palette.on_surface
    }

    Behavior on opacity {
        PropertyAnimation {
            duration: 150
            easing.type: Easing.InSine
        }

    }

}
