import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root

    property var sessionItems
    property alias sessionIndex: sessionBox.currentIndex

    signal powerOffClicked()
    signal rebootClicked()
    signal suspendClicked()

    implicitWidth: 380
    implicitHeight: 64
    radius: 32
    color: Qt.rgba(0, 0, 0, 0.5)
    border.color: Qt.rgba(1, 1, 1, 0.15)
    border.width: 1

    RowLayout {
        spacing: 10

        anchors {
            fill: parent
            leftMargin: 14
            rightMargin: 14
        }

        // Session Selector Dropdown
        ComboBox {
            id: sessionBox

            model: root.sessionItems
            Layout.fillWidth: true
            implicitHeight: 40
            textRole: "name"
            font.family: config.font ? config.font : "SF Pro Display"
            font.pixelSize: 13
            font.weight: Font.DemiBold

            background: Rectangle {
                radius: 20
                color: sessionBox.hovered ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(0, 0, 0, 0.35)
                border.color: sessionBox.visualFocus ? (config.primary ? config.primary : "#87d6bd") : Qt.rgba(1, 1, 1, 0.1)
                border.width: 1
            }

            indicator: Item {
                x: sessionBox.width - width - 12
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

            contentItem: RowLayout {
                spacing: 6

                anchors {
                    fill: parent
                    leftMargin: 12
                    rightMargin: 30
                }

                SvgIcon {
                    iconName: "session"
                    size: 16
                    color: config.on_surface ? config.on_surface : "#dee4e0"
                }

                Text {
                    text: sessionBox.displayText
                    font: sessionBox.font
                    color: config.on_surface ? config.on_surface : "#dee4e0"
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

            }

            delegate: ItemDelegate {
                id: itemDelegate

                width: sessionBox.width - 8
                implicitHeight: 34
                anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined

                contentItem: Text {
                    leftPadding: 12
                    rightPadding: 12
                    text: (typeof name !== "undefined" && name !== null) ? name : (typeof modelData !== "undefined" && modelData ? (modelData.name || modelData) : "")
                    color: itemDelegate.hovered ? (config.on_primary ? config.on_primary : "#00382c") : (config.on_surface ? config.on_surface : "#dee4e0")
                    font.family: config.font ? config.font : "SF Pro Display"
                    font.pixelSize: 13
                    font.weight: itemDelegate.hovered ? Font.Bold : Font.Normal
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 8
                    color: itemDelegate.hovered ? (config.primary ? config.primary : "#87d6bd") : "transparent"
                }

            }

            popup: Popup {
                y: sessionBox.height + 4
                width: sessionBox.width
                implicitHeight: Math.min(220, contentItem.implicitHeight + 12)
                padding: 4

                contentItem: ListView {
                    clip: true
                    spacing: 2
                    implicitHeight: contentHeight
                    model: sessionBox.popup.visible ? sessionBox.delegateModel : null
                    currentIndex: sessionBox.highlightedIndex
                }

                background: Rectangle {
                    border.color: Qt.rgba(1, 1, 1, 0.15)
                    border.width: 1
                    radius: 12
                    color: config.surface_container_high ? config.surface_container_high : "#252b29"
                }

            }

        }

        // Suspend Tile
        Rectangle {
            width: 40
            height: 40
            radius: 20
            color: suspMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.2) : Qt.rgba(0, 0, 0, 0.35)
            border.color: Qt.rgba(1, 1, 1, 0.1)
            border.width: 1

            SvgIcon {
                iconName: "suspend"
                size: 18
                color: config.on_surface ? config.on_surface : "#dee4e0"
                anchors.centerIn: parent
            }

            MouseArea {
                id: suspMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.suspendClicked()
            }

        }

        // Reboot Tile
        Rectangle {
            width: 40
            height: 40
            radius: 20
            color: rebMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.2) : Qt.rgba(0, 0, 0, 0.35)
            border.color: Qt.rgba(1, 1, 1, 0.1)
            border.width: 1

            SvgIcon {
                iconName: "reboot"
                size: 18
                color: config.on_surface ? config.on_surface : "#dee4e0"
                anchors.centerIn: parent
            }

            MouseArea {
                id: rebMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.rebootClicked()
            }

        }

        // Shutdown Tile
        Rectangle {
            width: 40
            height: 40
            radius: 20
            color: offMouse.containsMouse ? Qt.rgba(1, 0.3, 0.3, 0.4) : Qt.rgba(0, 0, 0, 0.35)
            border.color: offMouse.containsMouse ? (config.error ? config.error : "#ffb4ab") : Qt.rgba(1, 1, 1, 0.1)
            border.width: 1

            SvgIcon {
                iconName: "power"
                size: 18
                color: offMouse.containsMouse ? (config.error ? config.error : "#ffb4ab") : (config.on_surface ? config.on_surface : "#dee4e0")
                anchors.centerIn: parent
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
