import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root

    property var userItems
    property alias userIndex: userBox.currentIndex
    property alias password: textInput.text
    property string errorMessage: ""
    readonly property string iconFontFamily: config.iconFont ? config.iconFont : "Material Symbols Rounded, DankMono Nerd Font, FiraCode Nerd Font, symbols"

    signal loginRequested(string username, string password)
    signal focusPassword()

    onFocusPassword: textInput.forceActiveFocus()
    implicitWidth: 360
    implicitHeight: 85

    // Floating Error Tooltip Pill (above Auth Pill Card)
    Rectangle {
        id: errorPill

        visible: root.errorMessage !== ""
        opacity: root.errorMessage !== "" ? 1 : 0
        width: 220
        height: 36
        radius: 18
        color: config.error ? config.error : "#ffb4ab"

        anchors {
            bottom: authPillCard.top
            bottomMargin: 12
            horizontalCenter: parent.horizontalCenter
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: 6

            Text {
                text: "error"
                font.family: root.iconFontFamily
                font.pixelSize: 18
                color: config.on_error ? config.on_error : "#690005"
            }

            Text {
                text: root.errorMessage
                color: config.on_error ? config.on_error : "#690005"
                font.family: config.font ? config.font : "SF Pro Display"
                font.pixelSize: 13
                font.weight: Font.DemiBold
            }

        }

        Behavior on opacity {
            PropertyAnimation {
                duration: 150
            }

        }

    }

    // Main Auth Pill Card (Quickshell LockSurface Style)
    Rectangle {
        id: authPillCard

        anchors.fill: parent
        radius: 42
        color: Qt.rgba(0, 0, 0, 0.55)
        border.color: root.errorMessage !== "" ? (config.error ? config.error : "#ffb4ab") : Qt.rgba(1, 1, 1, 0.15)
        border.width: 1

        RowLayout {
            spacing: 8

            anchors {
                fill: parent
                leftMargin: 12
                rightMargin: 12
            }

            // User Avatar
            Rectangle {
                width: 54
                height: 54
                radius: 27
                color: config.primary_container ? config.primary_container : "#005141"
                border.color: config.primary ? config.primary : "#87d6bd"
                border.width: 2

                Text {
                    anchors.centerIn: parent
                    text: "person"
                    font.family: root.iconFontFamily
                    font.pixelSize: 28
                    color: config.on_primary_container ? config.on_primary_container : "#a2f2d8"
                }

            }

            // User ComboBox + Password Field Column
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                // User Selection Dropdown
                ComboBox {
                    id: userBox

                    model: root.userItems
                    Layout.fillWidth: true
                    implicitHeight: 24
                    textRole: "name"
                    font.family: config.font ? config.font : "SF Pro Display"
                    font.pixelSize: 13
                    font.weight: Font.Bold

                    background: Rectangle {
                        color: "transparent"
                    }

                    contentItem: Text {
                        text: userBox.displayText
                        font: userBox.font
                        color: config.on_surface ? config.on_surface : "#dee4e0"
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                }

                // Password Pill Input Container
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 36
                    radius: 18
                    color: Qt.rgba(0, 0, 0, 0.35)
                    border.color: textInput.activeFocus ? (config.primary ? config.primary : "#87d6bd") : Qt.rgba(1, 1, 1, 0.1)
                    border.width: 1

                    TextInput {
                        id: textInput

                        color: config.on_surface ? config.on_surface : "#dee4e0"
                        font.family: config.font ? config.font : "SF Pro Display"
                        font.pixelSize: 14
                        echoMode: TextInput.Password
                        clip: true
                        onAccepted: {
                            if (userBox.count > 0) {
                                var uname = userBox.model.get ? userBox.model.get(userBox.currentIndex).name : userBox.currentText;
                                root.loginRequested(uname, textInput.text);
                            }
                        }

                        anchors {
                            left: parent.left
                            right: toggleBtn.left
                            leftMargin: 12
                            rightMargin: 6
                            verticalCenter: parent.verticalCenter
                        }

                        Text {
                            anchors.fill: parent
                            text: "Password..."
                            color: config.on_surface_variant ? config.on_surface_variant : "#bfc9c4"
                            font: textInput.font
                            visible: !textInput.text && !textInput.activeFocus
                            verticalAlignment: Text.AlignVCenter
                        }

                    }

                    // Eye Reveal Toggle
                    Rectangle {
                        id: toggleBtn

                        width: 28
                        height: 28
                        radius: 14
                        color: toggleMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : "transparent"

                        anchors {
                            right: parent.right
                            rightMargin: 4
                            verticalCenter: parent.verticalCenter
                        }

                        Text {
                            anchors.centerIn: parent
                            text: textInput.echoMode === TextInput.Password ? "visibility" : "visibility_off"
                            font.family: root.iconFontFamily
                            color: config.on_surface_variant ? config.on_surface_variant : "#bfc9c4"
                            font.pixelSize: 16
                        }

                        MouseArea {
                            id: toggleMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                textInput.echoMode = (textInput.echoMode === TextInput.Password) ? TextInput.Normal : TextInput.Password;
                            }
                        }

                    }

                }

            }

            // Unlock Arrow Button
            Rectangle {
                width: 44
                height: 44
                radius: 22
                color: unlockMouse.pressed ? (config.primary_container ? config.primary_container : "#005141") : (unlockMouse.containsMouse ? (config.primary ? config.primary : "#87d6bd") : Qt.rgba(1, 1, 1, 0.12))
                border.color: config.primary ? config.primary : "#87d6bd"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "arrow_forward"
                    font.family: root.iconFontFamily
                    color: unlockMouse.containsMouse ? (config.on_primary ? config.on_primary : "#00382c") : (config.on_surface ? config.on_surface : "#dee4e0")
                    font.pixelSize: 20
                }

                MouseArea {
                    id: unlockMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (userBox.count > 0) {
                            var uname = userBox.model.get ? userBox.model.get(userBox.currentIndex).name : userBox.currentText;
                            root.loginRequested(uname, textInput.text);
                        }
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }

                }

            }

        }

    }

}
