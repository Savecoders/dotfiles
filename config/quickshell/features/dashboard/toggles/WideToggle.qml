import QtQuick
import QtQuick.Layouts
import qs.core

BaseToggle {
    id: root

    property string bigText: "Placeholder"
    property string smallText: "Placeholder"
    property int bigTextSize: Styling.fontSize.lg
    property int smallTextSize: bigTextSize - 2
    property string iconCode: "settings"
    property real iconSize: 25

    rWidth: 234
    rHeight: 87

    RowLayout {
        anchors.centerIn: parent
        width: root.rWidth - 10
        height: root.rHeight - 10
        spacing: Styling.spacing.none

        Item {
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            Layout.leftMargin: 25
            Layout.preferredWidth: root.rWidth / 10
            Layout.preferredHeight: root.rHeight / 2

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
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            Layout.leftMargin: 15
            Layout.preferredWidth: root.rWidth * 0.7
            Layout.preferredHeight: root.rHeight / 1.5

            TextMetrics {
                id: bigTextMetrics

                text: root.bigText
                font.family: (Config.settings && Config.settings.font) ? Config.settings.font : "SF Pro Display"
                elideWidth: root.rWidth - 65
                elide: Text.ElideRight
            }

            Text {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: parent.height / 5
                text: bigTextMetrics.elidedText
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

            TextMetrics {
                id: smallTextMetrics

                text: root.smallText
                font.family: (Config.settings && Config.settings.font) ? Config.settings.font : "SF Pro Display"
                elideWidth: root.rWidth - 65
                elide: Text.ElideRight
            }

            Text {
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.bottomMargin: parent.height / 6
                text: smallTextMetrics.elidedText
                font.family: (Config.settings && Config.settings.font) ? Config.settings.font : "SF Pro Display"
                font.pixelSize: root.smallTextSize
                font.weight: 500
                color: Qt.alpha(root.getColour(), 0.7)

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
