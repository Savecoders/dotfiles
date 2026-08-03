import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root

    property string fullDate: ""
    property var sessionItems
    property alias sessionIndex: sessionBox.currentIndex

    signal powerOffClicked()
    signal rebootClicked()
    signal suspendClicked()

    height: 60

    anchors {
        left: parent.left
        right: parent.right
        top: parent.top
        margins: 24
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var d = new Date();
            root.fullDate = Qt.formatDateTime(d, config.dateFormat ? config.dateFormat : "dddd, MMMM d");
        }
    }

    // Date on top left
    Text {
        text: root.fullDate
        color: config.on_surface ? config.on_surface : "#dee4e0"
        font.family: config.font ? config.font : "SF Pro Display"
        font.pixelSize: 18
        font.weight: Font.DemiBold

        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }

    }

    // Right controls: Session ComboBox & Power buttons
    RowLayout {
        spacing: 12

        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        // Session Selector Dropdown
        ComboBox {
            id: sessionBox

            model: root.sessionItems
            implicitWidth: 150
            implicitHeight: 38
            textRole: "name"
            font.family: config.font ? config.font : "SF Pro Display"
            font.pixelSize: 13

            background: Rectangle {
                radius: 12
                color: sessionBox.hovered ? (config.surface_container_high ? config.surface_container_high : "#252b29") : (config.surface_container ? config.surface_container : "#1b211e")
                border.color: sessionBox.visualFocus ? (config.primary ? config.primary : "#87d6bd") : Qt.rgba(1, 1, 1, 0.1)
                border.width: 1
            }

            indicator: Item {
                x: sessionBox.width - width - 10
                anchors.verticalCenter: sessionBox.verticalCenter
                width: 14
                height: 14

                SvgIcon {
                    iconName: "chevron_down"
                    size: 14
                    color: config.on_surface ? config.on_surface : "#dee4e0"
                    anchors.centerIn: parent
                }

            }

            contentItem: Text {
                leftPadding: 12
                text: sessionBox.displayText
                font: sessionBox.font
                color: config.on_surface ? config.on_surface : "#dee4e0"
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

        }

        // Suspend
        IconButton {
            text: "🌙"
            implicitWidth: 38
            implicitHeight: 38
            onClicked: root.suspendClicked()
        }

        // Reboot
        IconButton {
            text: "🔄"
            implicitWidth: 38
            implicitHeight: 38
            onClicked: root.rebootClicked()
        }

        // Shutdown
        IconButton {
            text: "⏻"
            implicitWidth: 38
            implicitHeight: 38
            onClicked: root.powerOffClicked()
        }

    }

}
