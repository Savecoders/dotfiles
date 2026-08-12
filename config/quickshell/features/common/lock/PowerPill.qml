import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root

    property Theme theme: themeDefault
    property var sessionItems
    property alias sessionIndex: sessionBox.currentIndex
    property Component statusComponent
    property bool showStatus: true
    property bool showPowerBtn: true
    readonly property bool hasSessions: root.sessionItems != null && root.sessionItems !== undefined && (root.sessionItems.count === undefined || root.sessionItems.count > 0)

    signal powerOffClicked()
    signal rebootClicked()
    signal suspendClicked()

    implicitWidth: 380
    implicitHeight: 64
    radius: root.theme.cardRadius
    color: root.theme.cardColor
    border.color: root.theme.cardBorderColor
    border.width: 1

    Theme {
        id: themeDefault
    }

    RowLayout {
        spacing: 8

        anchors {
            fill: parent
            leftMargin: 16
            rightMargin: 16
        }

        Loader {
            id: statusLoader

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            visible: !root.hasSessions && root.showStatus
            sourceComponent: root.statusComponent
        }

        // Session Selector Dropdown
        ComboBox {
            id: sessionBox

            visible: root.hasSessions
            model: root.sessionItems
            Layout.fillWidth: true
            implicitHeight: 40
            textRole: "name"
            font.family: root.theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.DemiBold

            background: Rectangle {
                radius: Math.max(2, root.theme.innerRadius)
                color: sessionBox.hovered ? root.theme.hoverOverlay : root.theme.pillColor
                border.color: sessionBox.visualFocus ? root.theme.primary : root.theme.pillBorderColor
                border.width: 1
            }

            indicator: Item {
                x: sessionBox.width - width - 12
                anchors.verticalCenter: sessionBox.verticalCenter
                width: 16
                height: 16

                Text {
                    text: "arrow_drop_down"
                    font.family: root.theme.iconFontFamily
                    font.pixelSize: 16
                    color: root.theme.on_surface
                    anchors.centerIn: parent
                }

            }

            contentItem: RowLayout {
                spacing: 8

                anchors {
                    fill: parent
                    leftMargin: 12
                    rightMargin: 32
                }

                Text {
                    text: "desktop_windows"
                    font.family: root.theme.iconFontFamily
                    font.pixelSize: 16
                    color: root.theme.on_surface
                }

                Text {
                    text: sessionBox.displayText
                    font: sessionBox.font
                    color: root.theme.on_surface
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

            }

            delegate: ItemDelegate {
                id: itemDelegate

                width: sessionBox.width - 8
                implicitHeight: 36
                anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined

                contentItem: Text {
                    leftPadding: 12
                    rightPadding: 12
                    text: (typeof name !== "undefined" && name !== null) ? name : (typeof modelData !== "undefined" && modelData ? (modelData.name || modelData) : "")
                    color: itemDelegate.hovered ? root.theme.on_primary : root.theme.on_surface
                    font.family: root.theme.fontFamily
                    font.pixelSize: 12
                    font.weight: itemDelegate.hovered ? Font.Bold : Font.Normal
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: Math.max(2, Math.round(root.theme.innerRadius / 4))
                    color: itemDelegate.hovered ? root.theme.primary : "transparent"
                }

            }

            popup: Popup {
                y: sessionBox.height + 4
                width: sessionBox.width
                implicitHeight: Math.min(220, contentItem.implicitHeight + 12)
                padding: 4

                contentItem: ListView {
                    clip: true
                    spacing: 4
                    implicitHeight: contentHeight
                    model: sessionBox.popup.visible ? sessionBox.delegateModel : null
                    currentIndex: sessionBox.highlightedIndex
                }

                background: Rectangle {
                    border.color: root.theme.cardBorderColor
                    border.width: 1
                    radius: Math.max(4, Math.round(root.theme.innerRadius / 2))
                    color: root.theme.surfaceContainerHigh
                }

            }

        }

        TextIconButton {
            theme: root.theme
            iconName: "bedtime"
            onClicked: root.suspendClicked()
        }

        TextIconButton {
            theme: root.theme
            iconName: "restart_alt"
            onClicked: root.rebootClicked()
        }

        TextIconButton {
            theme: root.theme
            iconName: "power_settings_new"
            danger: true
            visible: root.showPowerBtn
            onClicked: root.powerOffClicked()
        }

    }

}
