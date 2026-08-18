import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "components"

Rectangle {
    id: root

    property bool isUnlocked: false
    property int userIndex: (typeof userModel !== "undefined" && userModel && userModel.lastIndex !== undefined && userModel.lastIndex >= 0) ? userModel.lastIndex : 0
    property string errorMessage: ""
    property var usersList: []
    readonly property var currentUser: (root.usersList && root.userIndex >= 0 && root.userIndex < root.usersList.length) ? root.usersList[root.userIndex] : null
    readonly property string currentUsername: {
        if (currentUser && currentUser.name && currentUser.name.length > 0)
            return currentUser.name;

        if (typeof userModel !== "undefined" && userModel && userModel.lastUser && userModel.lastUser.length > 0)
            return userModel.lastUser;

        return "save";
    }
    readonly property string currentRealName: {
        if (currentUser) {
            if (currentUser.realName && currentUser.realName.length > 0)
                return currentUser.realName;

            if (currentUser.name && currentUser.name.length > 0)
                return currentUser.name;

        }
        return root.currentUsername;
    }
    readonly property string currentAvatarPath: {
        if (currentUser && currentUser.icon && currentUser.icon.length > 0)
            return currentUser.icon;

        return "";
    }
    readonly property Theme
    theme: Theme {
        primary: config.primary ? config.primary : "#87d6bd"
        on_primary: config.on_primary ? config.on_primary : "#00382c"
        primaryContainer: config.primary_container ? config.primary_container : "#005141"
        on_primary_container: config.on_primary_container ? config.on_primary_container : "#a2f2d8"
        primaryFixedDim: config.primary_fixed_dim ? config.primary_fixed_dim : "#90d1de"
        error: config.error ? config.error : "#ffb4ab"
        on_error: config.on_error ? config.on_error : "#690005"
        on_surface: config.on_surface ? config.on_surface : "#dee4e0"
        on_surface_variant: config.on_surface_variant ? config.on_surface_variant : "#bfc9c4"
        surfaceContainerHigh: config.surface_container_high ? config.surface_container_high : "#252b29"
        fontFamily: config.font ? config.font : "SF Pro Display"
        iconFontFamily: (iconFontLoader.status === FontLoader.Ready && iconFontLoader.name !== "") ? iconFontLoader.name : (config.iconFont ? config.iconFont : "Material Symbols Rounded")
        cardRadius: config.borderRadius ? Number(config.borderRadius) : 32
    }

    function activateLogin() {
        root.isUnlocked = true;
        loginPanel.focusPassword();
    }

    width: Screen.width
    height: Screen.height
    color: config.surface ? config.surface : "#0f1512"

    Instantiator {
        id: userCollector

        model: (typeof userModel !== "undefined" && userModel) ? userModel : null
        onObjectAdded: (idx, obj) => {
            var list = root.usersList.slice();
            list[idx] = {
                "name": obj.uName,
                "realName": obj.uRealName,
                "icon": obj.uIcon
            };
            root.usersList = list;
        }

        delegate: QtObject {
            property string uName: (typeof name !== "undefined" && name) ? name : ""
            property string uRealName: (typeof realName !== "undefined" && realName) ? realName : ""
            property string uIcon: (typeof icon !== "undefined" && icon) ? icon : ""
        }

    }

    FontLoader {
        id: iconFontLoader

        source: Qt.resolvedUrl("fonts/MaterialSymbolsRounded.ttf")
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

    // Dark Overlay & Global Click/Key Listener (idle → active state)
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: root.activateLogin()
    }

    Item {
        focus: true
        Keys.onPressed: (event) => {
            root.activateLogin();
        }
    }

    ClockHeader {
        id: centeredHeader

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -80
        theme: root.theme
    }

    Item {
        id: unlockPrompt

        width: 360
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
            font.family: root.theme.fontFamily
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

        Behavior on opacity {
            NumberAnimation {
                duration: 250
            }

        }

    }

    RowLayout {
        id: bottomHorizontalBar

        spacing: 16
        opacity: root.isUnlocked ? 1 : 0
        scale: root.isUnlocked ? 1 : 0.95
        visible: opacity > 0

        anchors {
            bottom: parent.bottom
            bottomMargin: 36
            horizontalCenter: parent.horizontalCenter
        }

        LoginPill {
            id: loginPanel

            theme: root.theme
            userItems: (typeof userModel !== "undefined" && userModel) ? userModel : null
            userIndex: root.userIndex
            userName: root.currentRealName
            userLogin: root.currentUsername
            avatarPath: root.currentAvatarPath
            avatarFallback: Qt.resolvedUrl("icon.png")
            errorMessage: root.errorMessage
            onUserSelected: (index) => {
                root.userIndex = index;
                loginPanel.focusPassword();
            }
            onUserSwitchRequested: {
                if (typeof userModel !== "undefined" && userModel) {
                    var total = (typeof userModel.rowCount === "function") ? userModel.rowCount() : (userModel.count || 1);
                    if (total > 1) {
                        root.userIndex = (root.userIndex + 1) % total;
                        loginPanel.focusPassword();
                    }
                }
            }
            onLoginRequested: (username, password) => {
                root.errorMessage = "";
                var targetUser = username || root.currentUsername;
                if (typeof sddm !== "undefined")
                    sddm.login(targetUser, password, powerBar.sessionIndex);
                else
                    console.log("SDDM Login simulation:", targetUser, password, powerBar.sessionIndex);
            }
        }

        PowerPill {
            id: powerBar

            theme: root.theme
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

        Behavior on opacity {
            NumberAnimation {
                duration: 300
            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutBack
            }

        }

    }

    Connections {
        function onLoginFailed() {
            root.errorMessage = "Incorrect password";
        }

        target: typeof sddm !== "undefined" ? sddm : null
    }

}
