import QtQuick
import QtQuick.Controls

Rectangle {
    id: root

    property alias text: textInput.text
    property alias echoMode: textInput.echoMode
    property alias textInput: textInput
    property string placeholder: "Password"

    signal accepted()

    implicitWidth: 280
    implicitHeight: 46
    radius: 14
    color: Qt.rgba(0, 0, 0, 0.4)
    border.color: textInput.activeFocus ? (config.primary ? config.primary : "#87d6bd") : (config.outline_variant ? config.outline_variant : "#3f4945")
    border.width: textInput.activeFocus ? 2 : 1

    TextInput {
        id: textInput

        color: config.on_surface ? config.on_surface : "#dee4e0"
        font.family: config.font ? config.font : "SF Pro Display"
        font.pixelSize: 15
        echoMode: TextInput.Password
        focus: true
        clip: true
        onAccepted: root.accepted()

        anchors {
            left: parent.left
            right: togglePassBtn.left
            leftMargin: 16
            rightMargin: 8
            verticalCenter: parent.verticalCenter
        }

        Text {
            anchors.fill: parent
            text: root.placeholder
            color: config.on_surface_variant ? config.on_surface_variant : "#bfc9c4"
            font: textInput.font
            visible: !textInput.text && !textInput.activeFocus
            verticalAlignment: Text.AlignVCenter
        }

    }

    Rectangle {
        id: togglePassBtn

        width: 32
        height: 32
        radius: 8
        color: toggleMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

        anchors {
            right: parent.right
            rightMargin: 8
            verticalCenter: parent.verticalCenter
        }

        Text {
            anchors.centerIn: parent
            text: textInput.echoMode === TextInput.Password ? "👁" : "🔒"
            color: config.on_surface_variant ? config.on_surface_variant : "#bfc9c4"
            font.pixelSize: 14
        }

        MouseArea {
            id: toggleMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (textInput.echoMode === TextInput.Password)
                    textInput.echoMode = TextInput.Normal;
                else
                    textInput.echoMode = TextInput.Password;
            }
        }

    }

    Behavior on border.color {
        ColorAnimation {
            duration: 150
        }

    }

}
