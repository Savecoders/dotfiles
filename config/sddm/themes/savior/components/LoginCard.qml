import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root

    property var userItems
    property alias userIndex: userBox.currentIndex
    property alias password: passwordInput.text
    property string errorMessage: ""

    signal loginRequested(string username, string password)
    signal focusPassword()

    onFocusPassword: passwordInput.textInput.forceActiveFocus()
    implicitWidth: 340
    implicitHeight: loginColumn.implicitHeight + 40
    radius: 24
    color: Qt.rgba(0, 0, 0, 0.45)
    border.color: Qt.rgba(1, 1, 1, 0.12)
    border.width: 1

    ColumnLayout {
        id: loginColumn

        spacing: 16

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 20
            leftMargin: 20
            rightMargin: 20
        }

        // User Avatar / Icon
        Rectangle {
            width: 72
            height: 72
            radius: 36
            color: config.primary_container ? config.primary_container : "#005141"
            border.color: config.primary ? config.primary : "#87d6bd"
            border.width: 2
            Layout.alignment: Qt.AlignHCenter

            Text {
                anchors.centerIn: parent
                text: "👤"
                font.pixelSize: 32
            }

        }

        // Username Selector
        ComboBox {
            id: userBox

            model: root.userItems
            Layout.fillWidth: true
            implicitHeight: 42
            textRole: "name"
            font.family: config.font ? config.font : "SF Pro Display"
            font.pixelSize: 14
            font.weight: Font.DemiBold

            background: Rectangle {
                radius: 12
                color: userBox.hovered ? (config.surface_container_high ? config.surface_container_high : "#252b29") : (config.surface_container ? config.surface_container : "#1b211e")
                border.color: userBox.visualFocus ? (config.primary ? config.primary : "#87d6bd") : Qt.rgba(1, 1, 1, 0.1)
                border.width: 1
            }

            indicator: Item {
                x: userBox.width - width - 10
                anchors.verticalCenter: userBox.verticalCenter
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
                leftPadding: 14
                text: userBox.displayText
                font: userBox.font
                color: config.on_surface ? config.on_surface : "#dee4e0"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }

        }

        // Password Input Field
        InputField {
            id: passwordInput

            Layout.fillWidth: true
            placeholder: "Enter Password..."
            onAccepted: {
                if (userBox.count > 0) {
                    var username = userBox.model.get ? userBox.model.get(userBox.currentIndex).name : userBox.currentText;
                    root.loginRequested(username, passwordInput.text);
                }
            }
        }

        // Error message banner
        Text {
            visible: root.errorMessage !== ""
            text: root.errorMessage
            color: config.error ? config.error : "#ffb4ab"
            font.family: config.font ? config.font : "SF Pro Display"
            font.pixelSize: 13
            font.weight: Font.Medium
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
        }

        // Login Action Button
        IconButton {
            text: "Unlock ➔"
            Layout.fillWidth: true
            implicitHeight: 44
            defaultColor: config.primary ? config.primary : "#87d6bd"
            hoverColor: config.primary_fixed_dim ? config.primary_fixed_dim : "#90d1de"
            textColor: config.on_primary ? config.on_primary : "#00382c"
            onClicked: {
                if (userBox.count > 0) {
                    var username = userBox.model.get ? userBox.model.get(userBox.currentIndex).name : userBox.currentText;
                    root.loginRequested(username, passwordInput.text);
                }
            }
        }

    }

}
