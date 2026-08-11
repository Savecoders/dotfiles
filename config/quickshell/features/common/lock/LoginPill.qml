import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root

    property Theme theme: themeDefault
    property string userName: "User"
    property string userLogin: "user"
    property string avatarPath: ""
    property url avatarFallback: ""
    property bool canSwitchUser: false
    property string password: ""
    property string errorMessage: ""

    signal loginRequested(string username, string password)

    Theme {
        id: themeDefault
    }
    signal userSwitchRequested()

    implicitWidth: 380
    implicitHeight: 64
    radius: root.theme.cardRadius
    color: root.theme.cardColor
    border.color: root.errorMessage !== "" ? root.theme.error : root.theme.cardBorderColor
    border.width: 1

    onPasswordChanged: {
        if (textInput.text !== root.password)
            textInput.text = root.password;

    }

    function focusPassword() {
        textInput.forceActiveFocus();
    }

    // Floating Error Message Pill above LoginPill
    Rectangle {
        visible: root.errorMessage !== ""
        opacity: root.errorMessage !== "" ? 1 : 0
        implicitWidth: errorRow.implicitWidth + 24
        implicitHeight: 32
        radius: Math.max(4, Math.round(root.theme.innerRadius / 2))
        color: root.theme.error
        anchors.bottom: parent.top
        anchors.bottomMargin: 12
        anchors.horizontalCenter: parent.horizontalCenter

        RowLayout {
            id: errorRow

            anchors.centerIn: parent
            spacing: 8

            Text {
                text: "warning"
                font.family: root.theme.iconFontFamily
                font.pixelSize: 16
                color: root.theme.on_error
            }

            Text {
                text: root.errorMessage
                color: root.theme.on_error
                font.family: root.theme.fontFamily
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

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 8

        // User Avatar (Circular with fallback)
        AvatarPill {
            theme: root.theme
            avatarPath: root.avatarPath
            fallbackSource: root.avatarFallback
            Layout.alignment: Qt.AlignVCenter
        }

        // Password Input Container
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            radius: Math.max(2, root.theme.innerRadius)
            color: root.theme.inputColor
            border.color: textInput.activeFocus ? root.theme.primary : root.theme.inputBorderColor
            border.width: textInput.activeFocus ? 2 : 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 12
                spacing: 8

                Text {
                    text: "lock"
                    font.family: root.theme.iconFontFamily
                    font.pixelSize: 20
                    color: textInput.activeFocus ? root.theme.primary : root.theme.on_surface_variant
                    Layout.alignment: Qt.AlignVCenter
                }

                TextInput {
                    id: textInput

                    Layout.fillWidth: true
                    color: root.theme.on_surface
                    font.family: root.theme.fontFamily
                    font.pixelSize: 16
                    echoMode: TextInput.Password
                    passwordCharacter: "•"
                    clip: true
                    verticalAlignment: Text.AlignVCenter
                    onTextChanged: {
                        if (root.password !== textInput.text)
                            root.password = textInput.text;

                    }
                    onAccepted: root.loginRequested(root.userLogin, textInput.text)

                    Text {
                        anchors.fill: parent
                        text: "Password"
                        color: root.theme.on_surface_variant
                        font: textInput.font
                        visible: !textInput.text && !textInput.activeFocus
                        verticalAlignment: Text.AlignVCenter
                    }

                }

                // Eye Reveal Toggle Button
                Rectangle {
                    width: 32
                    height: 32
                    radius: Math.max(2, root.theme.innerRadius)
                    color: eyeMouse.containsMouse ? root.theme.hoverOverlay : "transparent"

                    Text {
                        text: textInput.echoMode === TextInput.Password ? "visibility" : "visibility_off"
                        font.family: root.theme.iconFontFamily
                        font.pixelSize: 20
                        color: root.theme.on_surface_variant
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

        // Unlock Action Button (Circular Arrow)
        Rectangle {
            id: unlockBtn

            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: Math.max(2, root.theme.innerRadius)
            color: unlockMouse.pressed ? root.theme.primaryContainer : (unlockMouse.containsMouse ? root.theme.primaryFixedDim : root.theme.primary)
            border.color: root.theme.primary
            border.width: 1

            Text {
                text: "arrow_forward"
                font.family: root.theme.iconFontFamily
                font.pixelSize: 20
                color: root.theme.on_primary
                anchors.centerIn: parent
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

    transform: Translate {
        id: shakeTranslate

        x: 0
    }

    Connections {
        function onErrorMessageChanged() {
            if (root.errorMessage !== "")
                shakeAnim.restart();

        }

        target: root
    }

    SequentialAnimation {
        id: shakeAnim

        NumberAnimation {
            target: shakeTranslate
            property: "x"
            to: -12
            duration: 50
        }

        NumberAnimation {
            target: shakeTranslate
            property: "x"
            to: 12
            duration: 50
        }

        NumberAnimation {
            target: shakeTranslate
            property: "x"
            to: -8
            duration: 50
        }

        NumberAnimation {
            target: shakeTranslate
            property: "x"
            to: 8
            duration: 50
        }

        NumberAnimation {
            target: shakeTranslate
            property: "x"
            to: 0
            duration: 50
        }

    }

}
