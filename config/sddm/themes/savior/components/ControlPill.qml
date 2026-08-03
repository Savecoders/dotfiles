import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root

    property var sessionItems
    property alias sessionIndex: sessionBox.currentIndex
    readonly property string iconFontFamily: config.iconFont ? config.iconFont : "Material Symbols Rounded, DankMono Nerd Font, FiraCode Nerd Font, symbols"

    signal powerOffClicked()
    signal rebootClicked()
    signal suspendClicked()

    implicitWidth: 240
    implicitHeight: 85
    radius: 42
    color: Qt.rgba(0, 0, 0, 0.55)
    border.color: Qt.rgba(1, 1, 1, 0.15)
    border.width: 1

    RowLayout {
        spacing: 10

        anchors {
            fill: parent
            leftMargin: 16
            rightMargin: 16
        }

        // Session Selector Dropdown
        ComboBox {
            id: sessionBox

            model: root.sessionItems
            Layout.fillWidth: true
            implicitHeight: 38
            textRole: "name"
            font.family: config.font ? config.font : "SF Pro Display"
            font.pixelSize: 13
            font.weight: Font.DemiBold

            background: Rectangle {
                radius: 19
                color: sessionBox.hovered ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(0, 0, 0, 0.3)
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
                rightPadding: 12
                text: sessionBox.displayText
                font: sessionBox.font
                color: config.on_surface ? config.on_surface : "#dee4e0"
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

        }

        // Suspend Icon Button
        Rectangle {
            width: 38
            height: 38
            radius: 19
            color: suspMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.2) : Qt.rgba(0, 0, 0, 0.3)
            border.color: Qt.rgba(1, 1, 1, 0.1)
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "bedtime"
                font.family: root.iconFontFamily
                font.pixelSize: 18
                color: config.on_surface ? config.on_surface : "#dee4e0"
            }

            MouseArea {
                id: suspMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.suspendClicked()
            }

        }

        // Reboot Icon Button
        Rectangle {
            width: 38
            height: 38
            radius: 19
            color: rebMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.2) : Qt.rgba(0, 0, 0, 0.3)
            border.color: Qt.rgba(1, 1, 1, 0.1)
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "restart_alt"
                font.family: root.iconFontFamily
                font.pixelSize: 18
                color: config.on_surface ? config.on_surface : "#dee4e0"
            }

            MouseArea {
                id: rebMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.rebootClicked()
            }

        }

        // Shutdown Icon Button
        Rectangle {
            width: 38
            height: 38
            radius: 19
            color: offMouse.containsMouse ? Qt.rgba(1, 0.3, 0.3, 0.4) : Qt.rgba(0, 0, 0, 0.3)
            border.color: offMouse.containsMouse ? (config.error ? config.error : "#ffb4ab") : Qt.rgba(1, 1, 1, 0.1)
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "power_settings_new"
                font.family: root.iconFontFamily
                font.pixelSize: 18
                color: offMouse.containsMouse ? (config.error ? config.error : "#ffb4ab") : (config.on_surface ? config.on_surface : "#dee4e0")
            }

            MouseArea {
                id: offMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.powerOffClicked()
            }

        }

    }

}
