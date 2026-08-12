import QtQuick
import QtQuick.Layouts
import qs.core

StyledRect {
    id: root

    property int percent: 50
    property string iconName: "volume_up"
    property string labelText: percent + "%"

    function show() {
        if (fadeOut.running)
            fadeOut.stop();

        fadeIn.start();
        hideTimer.restart();
    }

    variant: "popup"
    width: 250
    height: 50
    color: Colours.palette.surface_container
    radius: Math.max(4, ((Config.settings && Config.settings.borderRadius !== undefined) ? Config.settings.borderRadius : 8) - 4)
    opacity: 0
    visible: false

    Timer {
        id: hideTimer

        interval: 2000
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
            duration: 100
        }

    }

    SequentialAnimation {
        id: fadeOut

        NumberAnimation {
            target: root
            property: "opacity"
            to: 0
            duration: 300
        }

        PropertyAction {
            target: root
            property: "visible"
            value: false
        }

    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        Text {
            text: root.iconName
            color: Colours.palette.on_surface
            font.family: (Config.settings && Config.settings.iconFont) ? Config.settings.iconFont : "Material Symbols Rounded"
            font.pixelSize: 20
        }

        StyledRect {
            variant: "internalbg"
            Layout.fillWidth: true
            height: 6
            color: Colours.palette.surface_container_high
            radius: 3

            StyledRect {
                variant: "common"
                width: parent.width * (Math.max(0, Math.min(100, root.percent)) / 100)
                height: parent.height
                color: Colours.palette.primary
                radius: 3

                Behavior on width {
                    PropertyAnimation {
                        duration: 80
                        easing.type: Easing.InSine
                    }

                }

            }

        }

        Text {
            text: root.labelText
            color: Colours.palette.on_surface
            font.family: (Config.settings && Config.settings.font) ? Config.settings.font : "SF Pro Display"
            font.pixelSize: 12
        }

    }

    Behavior on opacity {
        PropertyAnimation {
            duration: 150
            easing.type: Easing.InSine
        }

    }

}
