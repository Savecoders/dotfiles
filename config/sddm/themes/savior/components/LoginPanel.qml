import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root

    property string userName: "User"
    property string userLogin: "user"
    property string avatarPath: ""
    property bool canSwitchUser: false
    property alias password: textInput.text
    property string errorMessage: ""

    signal loginRequested(string username, string password)
    signal userSwitchRequested()
    signal focusPassword()

    onFocusPassword: textInput.forceActiveFocus()
    implicitWidth: 380
    implicitHeight: panelColumn.implicitHeight + 48
    radius: 28
    color: Qt.rgba(0, 0, 0, 0.5)
    border.color: root.errorMessage !== "" ? (config.error ? config.error : "#ffb4ab") : Qt.rgba(1, 1, 1, 0.15)
    border.width: 1

    ColumnLayout {
        id: panelColumn

        spacing: 18

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 24
            leftMargin: 24
            rightMargin: 24
        }

        // User Avatar & Selector
        UserAvatar {
            userName: root.userName
            userLogin: root.userLogin
            avatarPath: root.avatarPath
            canSwitchUser: root.canSwitchUser
            onUserSwitchClicked: root.userSwitchRequested()
            Layout.alignment: Qt.AlignHCenter
        }

        // Floating Error Message Pill
        Rectangle {
            visible: root.errorMessage !== ""
            opacity: root.errorMessage !== "" ? 1 : 0
            implicitWidth: errorRow.implicitWidth + 24
            implicitHeight: 32
            radius: 16
            color: config.error ? config.error : "#ffb4ab"
            Layout.alignment: Qt.AlignHCenter

            RowLayout {
                id: errorRow

                anchors.centerIn: parent
                spacing: 6

                SvgIcon {
                    iconName: "warning"
                    size: 16
                    color: config.on_error ? config.on_error : "#690005"
                }

                Text {
                    text: root.errorMessage
                    color: config.on_error ? config.on_error : "#690005"
                    font.family: config.font ? config.font : "SF Pro Display"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                }

            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }

            }

        }

        // Password Input Container
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 48
            radius: 24
            color: Qt.rgba(0, 0, 0, 0.4)
            border.color: textInput.activeFocus ? (config.primary ? config.primary : "#87d6bd") : Qt.rgba(1, 1, 1, 0.12)
            border.width: textInput.activeFocus ? 2 : 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 10
                spacing: 8

                SvgIcon {
                    iconName: "lock"
                    size: 18
                    color: textInput.activeFocus ? (config.primary ? config.primary : "#87d6bd") : (config.on_surface_variant ? config.on_surface_variant : "#bfc9c4")
                }

                TextInput {
                    id: textInput

                    Layout.fillWidth: true
                    color: config.on_surface ? config.on_surface : "#dee4e0"
                    font.family: config.font ? config.font : "SF Pro Display"
                    font.pixelSize: 15
                    echoMode: TextInput.Password
                    passwordCharacter: "•"
                    clip: true
                    onAccepted: root.loginRequested(root.userLogin, textInput.text)

                    Text {
                        anchors.fill: parent
                        text: "Password"
                        color: config.on_surface_variant ? config.on_surface_variant : "#bfc9c4"
                        font: textInput.font
                        visible: !textInput.text && !textInput.activeFocus
                        verticalAlignment: Text.AlignVCenter
                    }

                }

                // Eye Reveal Toggle Button
                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: eyeMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : "transparent"

                    SvgIcon {
                        iconName: textInput.echoMode === TextInput.Password ? "eye" : "eye_off"
                        size: 18
                        color: config.on_surface_variant ? config.on_surface_variant : "#bfc9c4"
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        id: eyeMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            textInput.echoMode = (textInput.echoMode === TextInput.Password) ? TextInput.Normal : TextInput.Password;
                        }
                    }

                }

            }

            Behavior on border.color {
                ColorAnimation {
                    duration: 150
                }

            }

        }

        // Unlock Action Button
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 46
            radius: 23
            color: unlockMouse.pressed ? (config.primary_container ? config.primary_container : "#005141") : (unlockMouse.containsMouse ? (config.primary_fixed_dim ? config.primary_fixed_dim : "#90d1de") : (config.primary ? config.primary : "#87d6bd"))
            border.color: config.primary ? config.primary : "#87d6bd"
            border.width: 1

            RowLayout {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    text: "UNLOCK"
                    color: config.on_primary ? config.on_primary : "#00382c"
                    font.family: config.font ? config.font : "SF Pro Display"
                    font.pixelSize: 13
                    font.weight: Font.ExtraBold
                    font.letterSpacing: 1.5
                }

                SvgIcon {
                    iconName: "arrow"
                    size: 18
                    color: config.on_primary ? config.on_primary : "#00382c"
                }

            }

            MouseArea {
                id: unlockMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.loginRequested(root.userLogin, textInput.text)
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }

            }

        }

    }

}
