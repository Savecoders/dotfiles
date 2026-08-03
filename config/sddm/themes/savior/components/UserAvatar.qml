import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property string userName: "User"
    property string userLogin: "user"
    property string avatarPath: ""
    property bool canSwitchUser: false

    signal userSwitchClicked()

    spacing: 12

    // Circular Avatar Image / Icon Container
    Rectangle {
        width: 84
        height: 84
        radius: 42
        color: config.primary_container ? config.primary_container : "#005141"
        border.color: config.primary ? config.primary : "#87d6bd"
        border.width: 3
        Layout.alignment: Qt.AlignHCenter

        Image {
            id: avatarImg

            anchors.fill: parent
            anchors.margins: 3
            source: root.avatarPath !== "" ? root.avatarPath : ""
            visible: status === Image.Ready
            fillMode: Image.PreserveAspectCrop
        }

        SvgIcon {
            visible: !avatarImg.visible
            iconName: "user"
            size: 40
            color: config.on_primary_container ? config.on_primary_container : "#a2f2d8"
            anchors.centerIn: parent
        }

    }

    // User Name Display & Switcher Chip
    Rectangle {
        implicitWidth: nameRow.implicitWidth + 28
        implicitHeight: 34
        radius: 17
        color: userSwitchMouse.containsMouse ? (config.surface_container_highest ? config.surface_container_highest : "#303633") : (config.surface_container ? config.surface_container : "#1b211e")
        border.color: Qt.rgba(1, 1, 1, 0.1)
        border.width: 1
        Layout.alignment: Qt.AlignHCenter

        RowLayout {
            id: nameRow

            anchors.centerIn: parent
            spacing: 6

            Text {
                text: root.userName !== "" ? root.userName : root.userLogin
                color: config.on_surface ? config.on_surface : "#dee4e0"
                font.family: config.font ? config.font : "SF Pro Display"
                font.pixelSize: 14
                font.weight: Font.Bold
            }

            SvgIcon {
                visible: root.canSwitchUser
                iconName: "user"
                size: 14
                color: config.primary ? config.primary : "#87d6bd"
            }

        }

        MouseArea {
            id: userSwitchMouse

            anchors.fill: parent
            enabled: root.canSwitchUser
            hoverEnabled: root.canSwitchUser
            cursorShape: root.canSwitchUser ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.userSwitchClicked()
        }

    }

}
