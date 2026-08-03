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

    // 1. Background Wallpaper Image (Synced with Quickshell ~/.current.wall via Matugen reload)
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

    // 2. Centered Idle Lock State (Clock & Date dead center at startup)
    Header {
        id: centeredHeader

        anchors.centerIn: parent
        opacity: root.isUnlocked ? 0 : 1
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: 300
            }

        }

    }

    // Unlock Prompt (Visible at startup below centered clock)
    Item {
        id: unlockPrompt

        width: 340
        height: 44
        opacity: root.isUnlocked ? 0 : 1
        visible: opacity > 0

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: centeredHeader.bottom
            topMargin: 36
        }

        Text {
            anchors.centerIn: parent
            text: "Click or press Enter to unlock"
            color: Qt.rgba(1, 1, 1, 0.85)
            font.family: config.font ? config.font : "SF Pro Display"
            font.pixelSize: 16
            font.weight: Font.Medium

            SequentialAnimation on opacity {
                running: !root.isUnlocked
                loops: Animation.Infinite

                NumberAnimation {
                    to: 0.3
                    duration: 1000
                }

                NumberAnimation {
                    to: 1
                    duration: 1000
                }

            }

        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.isUnlocked = true;
                loginPanel.focusPassword();
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 250
            }

        }

    }

    // 3. Side-by-Side Main Layout (Revealed on Click / Key press / Enter)
    // Left: Clock & Date | Right: Form (Login Panel + Power Bar)
    RowLayout {
        id: mainSideBySideRow

        anchors.centerIn: parent
        spacing: 72
        opacity: root.isUnlocked ? 1 : 0
        scale: root.isUnlocked ? 1 : 0.95
        visible: opacity > 0

        // LEFT: Clock & Date
        Header {
            id: sideHeader

            Layout.alignment: Qt.AlignVCenter
        }

        // RIGHT: Form Container (Login Panel + Power Bar)
        ColumnLayout {
            id: formContainer

            spacing: 18
            Layout.alignment: Qt.AlignVCenter

            // Login Panel
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

            // Quick Actions & Power Bar
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

        Behavior on opacity {
            NumberAnimation {
                duration: 400
            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutBack
            }

        }

    }

    // Global Key Listener (Reveals form on any key / Enter)
    Item {
        focus: true
        Keys.onPressed: (event) => {
            if (!root.isUnlocked) {
                root.isUnlocked = true;
                loginPanel.focusPassword();
            }
        }
    }

    // Global Mouse Area (Reveals form when clicking screen)
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: {
            if (!root.isUnlocked) {
                root.isUnlocked = true;
                loginPanel.focusPassword();
            }
        }
    }

    // SDDM Event Handlers
    Connections {
        function onLoginFailed() {
            root.errorMessage = "Incorrect Password";
            loginPanel.password = "";
            shakeAnimation.start();
        }

        function onLoginSucceeded() {
            root.errorMessage = "";
        }

        target: typeof sddm !== "undefined" ? sddm : null
    }

    // Shake Animation on wrong password
    SequentialAnimation {
        id: shakeAnimation

        NumberAnimation {
            target: formContainer
            property: "anchors.horizontalCenterOffset"
            to: -12
            duration: 50
        }

        NumberAnimation {
            target: formContainer
            property: "anchors.horizontalCenterOffset"
            to: 12
            duration: 50
        }

        NumberAnimation {
            target: formContainer
            property: "anchors.horizontalCenterOffset"
            to: -8
            duration: 50
        }

        NumberAnimation {
            target: formContainer
            property: "anchors.horizontalCenterOffset"
            to: 8
            duration: 50
        }

        NumberAnimation {
            target: formContainer
            property: "anchors.horizontalCenterOffset"
            to: 0
            duration: 50
        }

    }

}
