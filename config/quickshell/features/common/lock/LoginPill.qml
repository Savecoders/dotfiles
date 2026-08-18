import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Templates as T
import qs.core

StyledRect {
    id: root

    property Theme theme: themeDefault
    property var userItems: null
    property int userIndex: 0
    property string userName: "User"
    property string userLogin: "user"
    property string avatarPath: ""
    property url avatarFallback: ""
    property bool canSwitchUser: {
        if (!root.userItems)
            return false;

        if (typeof root.userItems.count === "number")
            return root.userItems.count > 1;

        if (typeof root.userItems.rowCount === "function")
            return root.userItems.rowCount() > 1;

        if (typeof root.userItems.length === "number")
            return root.userItems.length > 1;

        return true;
    }
    property string password: ""
    property string errorMessage: ""
    property var usersList: []
    readonly property var selectedUserObj: (root.usersList && root.userIndex >= 0 && root.userIndex < root.usersList.length) ? root.usersList[root.userIndex] : null
    readonly property string displayUserName: {
        if (selectedUserObj) {
            if (selectedUserObj.realName && selectedUserObj.realName.length > 0)
                return selectedUserObj.realName;

            if (selectedUserObj.name && selectedUserObj.name.length > 0)
                return selectedUserObj.name;

        }
        return root.userName !== "" ? root.userName : root.userLogin;
    }
    readonly property string displayUserLogin: {
        if (selectedUserObj && selectedUserObj.name && selectedUserObj.name.length > 0)
            return selectedUserObj.name;

        return root.userLogin !== "" ? root.userLogin : "user";
    }
    readonly property string displayAvatarPath: {
        if (selectedUserObj && selectedUserObj.icon && selectedUserObj.icon.length > 0)
            return selectedUserObj.icon;

        return root.avatarPath;
    }

    signal loginRequested(string username, string password)
    signal userSwitchRequested()
    signal userSelected(int index)

    function focusPassword() {
        textInput.forceActiveFocus();
    }

    variant: "pane"
    useDefaultRadius: false
    implicitWidth: 460
    implicitHeight: 64
    radius: root.theme.cardRadius
    color: root.theme.cardColor
    border.color: root.errorMessage !== "" ? root.theme.error : root.theme.cardBorderColor
    border.width: 1
    onPasswordChanged: {
        if (textInput.text !== root.password)
            textInput.text = root.password;

    }
    onUserIndexChanged: {
        if (userBox.currentIndex !== root.userIndex)
            userBox.currentIndex = root.userIndex;

    }

    Instantiator {
        id: internalUserCollector

        model: root.userItems
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

    Theme {
        id: themeDefault
    }

    StyledRect {
        variant: "internalbg"
        useDefaultRadius: false
        border.width: 0
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
            spacing: Styling.spacing.xl

            Text {
                text: "warning"
                font.family: root.theme.iconFontFamily
                font.pixelSize: Styling.fontSize.title
                color: root.theme.on_error
            }

            Text {
                text: root.errorMessage
                color: root.theme.on_error
                font.family: root.theme.fontFamily
                font.pixelSize: Styling.fontSize.body
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
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: Styling.spacing.lg

        // User Selector Dropdown (Avatar + Username + Dropdown Arrow)
        T.ComboBox {
            id: userBox

            readonly property var pillTheme: root.theme
            readonly property url defaultAvatar: root.avatarFallback

            Layout.preferredWidth: 160
            Layout.preferredHeight: 44
            Layout.alignment: Qt.AlignVCenter
            model: root.userItems
            currentIndex: root.userIndex
            enabled: root.canSwitchUser
            textRole: "name"
            font.family: root.theme.fontFamily
            font.pixelSize: Styling.fontSize.body
            font.weight: Font.DemiBold
            onActivated: (index) => {
                userBox.currentIndex = index;
                root.userIndex = index;
                root.userSelected(index);
                root.focusPassword();
            }
            onCurrentIndexChanged: {
                if (root.userIndex !== currentIndex && currentIndex >= 0) {
                    root.userIndex = currentIndex;
                    root.userSelected(currentIndex);
                }
            }

            background: StyledRect {
                variant: "internalbg"
                useDefaultRadius: false
                radius: Math.max(2, root.theme.innerRadius)
                color: userBox.hovered && root.canSwitchUser ? root.theme.hoverOverlay : root.theme.pillColor
                border.color: userBox.visualFocus ? root.theme.primary : root.theme.pillBorderColor
                border.width: 1
            }

            indicator: Item {
                visible: root.canSwitchUser
                x: userBox.width - width - 8
                anchors.verticalCenter: userBox.verticalCenter
                width: 16
                height: 16

                Text {
                    text: "arrow_drop_down"
                    font.family: root.theme.iconFontFamily
                    font.pixelSize: Styling.fontSize.title
                    color: root.theme.on_surface
                    anchors.centerIn: parent
                }

            }

            contentItem: RowLayout {
                spacing: Styling.spacing.md
                anchors.fill: parent
                anchors.leftMargin: 6
                anchors.rightMargin: root.canSwitchUser ? 24 : 8

                // User Avatar Circle
                StyledRect {
                    variant: "focus"
                    useDefaultRadius: false
                    width: 32
                    height: 32
                    radius: 16
                    color: root.theme.primaryContainer
                    border.color: root.theme.primary
                    border.width: 1.5
                    Layout.alignment: Qt.AlignVCenter

                    Image {
                        id: currentAvatarImg

                        anchors.fill: parent
                        anchors.margins: 2
                        sourceSize: Qt.size(28, 28)
                        fillMode: Image.PreserveAspectCrop
                        source: (root.displayAvatarPath && root.displayAvatarPath !== "") ? root.displayAvatarPath : root.avatarFallback
                        onStatusChanged: {
                            if ((status === Image.Error || status === Image.Null) && source !== root.avatarFallback)
                                source = root.avatarFallback;

                        }
                    }

                }

                // User Display Name
                Text {
                    text: root.displayUserName
                    font: userBox.font
                    color: root.theme.on_surface
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

            }

            delegate: ItemDelegate {
                id: userDelegate

                required property int index
                required property var model
                readonly property string userAvatarSrc: {
                    if (typeof icon !== "undefined" && typeof icon === "string" && icon !== "")
                        return icon;

                    if (typeof model !== "undefined" && model && typeof model.icon === "string" && model.icon !== "")
                        return model.icon;

                    if (typeof modelData !== "undefined" && modelData && typeof modelData.icon === "string" && modelData.icon !== "")
                        return modelData.icon;

                    return (userBox.defaultAvatar ? userBox.defaultAvatar.toString() : "");
                }
                readonly property string userDisplayName: {
                    if (typeof realName !== "undefined" && typeof realName === "string" && realName !== "")
                        return realName;

                    if (typeof name !== "undefined" && typeof name === "string" && name !== "")
                        return name;

                    if (typeof model !== "undefined" && model) {
                        if (typeof model.realName === "string" && model.realName !== "")
                            return model.realName;

                        if (typeof model.name === "string" && model.name !== "")
                            return model.name;

                    }
                    if (typeof modelData !== "undefined" && modelData) {
                        if (typeof modelData.realName === "string" && modelData.realName !== "")
                            return modelData.realName;

                        if (typeof modelData.name === "string" && modelData.name !== "")
                            return modelData.name;

                        if (typeof modelData === "string")
                            return modelData;

                    }
                    return "User";
                }

                width: userBox.width - 8
                implicitHeight: 40
                anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
                onClicked: {
                    userBox.currentIndex = userDelegate.index;
                    userBox.activated(userDelegate.index);
                    userBox.popup.close();
                }

                contentItem: RowLayout {
                    spacing: Styling.spacing.md
                    anchors.fill: parent
                    anchors.leftMargin: 6
                    anchors.rightMargin: 6

                    StyledRect {
                        variant: "focus"
                        useDefaultRadius: false
                        width: 26
                        height: 26
                        radius: 13
                        color: userBox.pillTheme.primaryContainer
                        border.color: userBox.pillTheme.primary
                        border.width: 1

                        Image {
                            anchors.fill: parent
                            anchors.margins: 1
                            sourceSize: Qt.size(24, 24)
                            fillMode: Image.PreserveAspectCrop
                            source: userDelegate.userAvatarSrc !== "" ? userDelegate.userAvatarSrc : userBox.defaultAvatar
                            onStatusChanged: {
                                if ((status === Image.Error || status === Image.Null) && source !== userBox.defaultAvatar)
                                    source = userBox.defaultAvatar;

                            }
                        }

                    }

                    Text {
                        text: userDelegate.userDisplayName
                        color: userDelegate.hovered ? userBox.pillTheme.on_primary : userBox.pillTheme.on_surface
                        font.family: userBox.pillTheme.fontFamily
                        font.pixelSize: Styling.fontSize.body
                        font.weight: userDelegate.hovered ? Font.Bold : Font.Normal
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                        Layout.fillWidth: true
                    }

                }

                background: StyledRect {
                    variant: "focus"
                    useDefaultRadius: false
                    border.width: 0
                    radius: Math.max(2, Math.round(userBox.pillTheme.innerRadius / 4))
                    color: userDelegate.hovered ? userBox.pillTheme.primary : "transparent"
                }

            }

            popup: Popup {
                y: userBox.height + 4
                width: userBox.width
                implicitHeight: Math.min(220, contentItem.implicitHeight + 12)
                padding: 4

                contentItem: ListView {
                    clip: true
                    spacing: Styling.spacing.sm
                    implicitHeight: contentHeight
                    model: userBox.popup.visible ? userBox.delegateModel : null
                    currentIndex: userBox.highlightedIndex
                }

                background: StyledRect {
                    variant: "popup"
                    useDefaultRadius: false
                    border.color: userBox.pillTheme.cardBorderColor
                    border.width: 1
                    radius: Math.max(4, Math.round(userBox.pillTheme.innerRadius / 2))
                    color: userBox.pillTheme.surfaceContainerHigh
                }

            }

        }

        // Password Input Container
        StyledRect {
            variant: "internalbg"
            useDefaultRadius: false
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            radius: Math.max(2, root.theme.innerRadius)
            color: root.theme.inputColor
            border.color: textInput.activeFocus ? root.theme.primary : root.theme.inputBorderColor
            border.width: textInput.activeFocus ? 2 : 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 10
                spacing: Styling.spacing.lg

                Text {
                    text: "lock"
                    font.family: root.theme.iconFontFamily
                    font.pixelSize: Styling.fontSize.xl
                    color: textInput.activeFocus ? root.theme.primary : root.theme.on_surface_variant
                    Layout.alignment: Qt.AlignVCenter
                }

                TextInput {
                    id: textInput

                    Layout.fillWidth: true
                    color: root.theme.on_surface
                    font.family: root.theme.fontFamily
                    font.pixelSize: Styling.fontSize.lg
                    echoMode: TextInput.Password
                    passwordCharacter: "•"
                    clip: true
                    verticalAlignment: Text.AlignVCenter
                    onTextChanged: {
                        if (root.password !== textInput.text)
                            root.password = textInput.text;

                    }
                    onAccepted: root.loginRequested(root.displayUserLogin, textInput.text)

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
                StyledRect {
                    variant: "common"
                    useDefaultRadius: false
                    border.width: 0
                    width: 32
                    height: 32
                    radius: Math.max(2, root.theme.innerRadius)
                    color: eyeMouse.containsMouse ? root.theme.hoverOverlay : "transparent"

                    Text {
                        text: textInput.echoMode === TextInput.Password ? "visibility" : "visibility_off"
                        font.family: root.theme.iconFontFamily
                        font.pixelSize: Styling.fontSize.xl
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
        StyledRect {
            id: unlockBtn

            variant: "focus"
            useDefaultRadius: false
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: Math.max(2, root.theme.innerRadius)
            color: unlockMouse.pressed ? root.theme.primaryContainer : (unlockMouse.containsMouse ? root.theme.primaryFixedDim : root.theme.primary)
            border.color: root.theme.primary
            border.width: 1

            Text {
                text: "arrow_forward"
                font.family: root.theme.iconFontFamily
                font.pixelSize: Styling.fontSize.xl
                color: root.theme.on_primary
                anchors.centerIn: parent
            }

            MouseArea {
                id: unlockMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.loginRequested(root.displayUserLogin, textInput.text)
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }

            }

        }

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

    transform: Translate {
        id: shakeTranslate

        x: 0
    }

}
