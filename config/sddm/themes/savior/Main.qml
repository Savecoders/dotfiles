import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Qt5Compat.GraphicalEffects
import "components"

Rectangle {
    id: root

    property bool isUnlocked: false
    property int userIndex: (typeof userModel !== "undefined" && userModel && userModel.lastIndex !== undefined && userModel.lastIndex >= 0) ? userModel.lastIndex : 0
    property string errorMessage: ""
    // OS Username & Real Name Resolver
    readonly property string currentUsername: {
        if (typeof userModel !== "undefined" && userModel) {
            if (userModel.get && userModel.rowCount && userModel.rowCount() > 0) {
                var u = userModel.get(root.userIndex);
                if (u && u.name)
                    return u.name;

            }
            if (userModel.lastUser && userModel.lastUser.length > 0)
                return userModel.lastUser;

        }
        return "salva";
    }
    readonly property string currentRealName: {
        if (typeof userModel !== "undefined" && userModel) {
            if (userModel.get && userModel.rowCount && userModel.rowCount() > 0) {
                var u2 = userModel.get(root.userIndex);
                if (u2 && u2.realName && u2.realName.length > 0)
                    return u2.realName;

                if (u2 && u2.name && u2.name.length > 0)
                    return u2.name;

            }
            if (userModel.lastUser && userModel.lastUser.length > 0)
                return userModel.lastUser;

        }
        return "Salva";
    }
    readonly property string currentAvatarPath: {
        if (typeof userModel !== "undefined" && userModel && userModel.get && userModel.rowCount && userModel.rowCount() > 0) {
            var item = userModel.get(root.userIndex);
            return item ? (item.icon || "") : "";
        }
        return "";
    }

    width: Screen.width
    height: Screen.height
    color: config.surface ? config.surface : "#0f1512"
    Component.onCompleted: {
        loginPanel.focusPassword();
    }

    Item {
        id: wallpaperContainer

        anchors.fill: parent

        Image {
            id: backgroundImage

            anchors.fill: parent
            source: config.background ? config.background : "background.png"
            fillMode: Image.PreserveAspectCrop
            asynchronous: false
            cache: false
            visible: false
        }

        // FastBlur background blur matching Quickshell
        FastBlur {
            id: blurEffect

            anchors.fill: parent
            source: backgroundImage
            radius: 32
            cached: false
        }

        // Subtle dark overlay
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.4)
        }

    }

    Header {
        id: centeredHeader

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -80
    }

    RowLayout {
        id: bottomHorizontalBar

        spacing: 16

        anchors {
            bottom: parent.bottom
            bottomMargin: 36
            horizontalCenter: parent.horizontalCenter
        }

        LoginPanel {
            id: loginPanel

            userName: root.currentRealName
            userLogin: root.currentUsername
            avatarPath: root.currentAvatarPath
            canSwitchUser: typeof userModel !== "undefined" && userModel && userModel.rowCount && userModel.rowCount() > 1
            errorMessage: root.errorMessage
            onUserSwitchRequested: {
                if (typeof userModel !== "undefined" && userModel && userModel.rowCount && userModel.rowCount() > 1)
                    root.userIndex = (root.userIndex + 1) % userModel.rowCount();

            }
            onLoginRequested: (username, password) => {
                root.errorMessage = "";
                if (typeof sddm !== "undefined")
                    sddm.login(username, password, powerBar.sessionIndex);
                else
                    console.log("SDDM Login simulation:", username, password, powerBar.sessionIndex);
            }
        }

        PowerBar {
            id: powerBar

            sessionItems: (typeof sessionModel !== "undefined" && sessionModel) ? sessionModel : null
            sessionIndex: (typeof sessionModel !== "undefined" && sessionModel && sessionModel.lastIndex >= 0) ? sessionModel.lastIndex : 0
            onPowerOffClicked: {
                if (typeof sddm !== "undefined")
                    sddm.powerOff();

            }
            onRebootClicked: {
                if (typeof sddm !== "undefined")
                    sddm.reboot();

            }
            onSuspendClicked: {
                if (typeof sddm !== "undefined")
                    sddm.suspend();

            }
        }

    }

    Item {
        focus: true
        Keys.onPressed: (event) => {
            loginPanel.focusPassword();
        }
    }

}
