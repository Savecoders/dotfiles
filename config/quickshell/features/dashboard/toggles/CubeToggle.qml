import QtQuick
import QtQuick.Layouts
import qs.core

BaseToggle {
    id: root

    property string bigText: "Placeholder"
    property int bigTextSize: Styling.fontSize.bodyLarge
    property string iconCode: "settings"
    property real iconSize: 25

    rWidth: 112
    rHeight: 87

    ColumnLayout {
        anchors.centerIn: parent
        width: root.rWidth - 10
        height: root.rHeight - 10
        spacing: Styling.spacing.none

        Item {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.topMargin: 15
            Layout.preferredWidth: root.rWidth / 10
            Layout.preferredHeight: root.rHeight / 10

            Text {
                anchors.centerIn: parent
                text: root.iconCode
                font.family: (Config.settings && Config.settings.iconFont) ? Config.settings.iconFont : "Material Symbols Rounded"
                font.pixelSize: root.iconSize
                font.weight: 500
                color: root.getColour()

                Behavior on color {
                    PropertyAnimation {
                        duration: (Config.settings && Config.settings.animationSpeed !== undefined) ? Config.settings.animationSpeed : 200
                        easing.type: Easing.InSine
                    }

                }

            }

        }

        Item {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.topMargin: 10
            Layout.preferredWidth: root.rWidth * 0.6
            Layout.preferredHeight: root.rHeight / 4

            Text {
                anchors.centerIn: parent
                text: root.bigText
                font.family: (Config.settings && Config.settings.font) ? Config.settings.font : "SF Pro Display"
                font.pixelSize: root.bigTextSize
                font.weight: 500
                color: root.getColour()

                Behavior on color {
                    PropertyAnimation {
                        duration: (Config.settings && Config.settings.animationSpeed !== undefined) ? Config.settings.animationSpeed : 200
                        easing.type: Easing.InSine
                    }

                }

            }

        }

    }

}
