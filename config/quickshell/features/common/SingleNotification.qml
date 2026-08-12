/*
Summary:     modelData.summary
Body:        modelData.body
Icon Path:   Qt.resolvedUrl(modelData.appIcon)
Time:        NotificationUtils.getFriendlyNotifTimeString(modelData.time)
App Name:    modelData.appName
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Widgets
import qs.core
import qs.features.common
import qs.services
import "root:/lib/notification_utils.js" as NotificationUtils

ClippingRectangle {
    id: singleNotif

    property bool popup: false
    property bool expanded: false
    property bool areActions: modelData ? (modelData.actions && modelData.actions.length > 0) : false
    property int currentTime: 4000
    property var actions: modelData ? modelData.actions : []

    function startTimeout() {
        dismissTimer.stop();
        dismissTimer.interval = singleNotif.currentTime;
        if (timeoutBar.parent)
            timeoutBar.width = timeoutBar.parent.width;

        timeoutShrink.stop();
        timeoutShrink.duration = singleNotif.currentTime;
        timeoutShrink.restart();
        dismissTimer.start();
    }

    function handleSmartClick() {
        if (!modelData)
            return ;

        // 1. If notification has custom action buttons from sender, invoke default action
        if (modelData.actions && modelData.actions.length > 0) {
            let defAction = modelData.actions.find((a) => {
                return a.identifier === "default";
            }) || modelData.actions[0];
            if (defAction) {
                Notifications.attemptInvokeAction(modelData.notificationId, defAction.identifier);
                return ;
            }
        }
        // 2. Extract potential image or file path from image property, body text, or summary
        let pathCandidate = "";
        if (modelData.image && modelData.image.length > 0) {
            pathCandidate = modelData.image;
        } else if (modelData.body && modelData.body.length > 0) {
            let match = modelData.body.match(/(\/(?:[^\s'"\(\)]+)|~\/(?:[^\s'"\(\)]+)|Pictures\/(?:[^\s'"\(\)]+)|Downloads\/(?:[^\s'"\(\)]+)|Videos\/(?:[^\s'"\(\)]+))/);
            if (match && match[1]) {
                pathCandidate = match[1];
                if (pathCandidate.startsWith("Pictures/"))
                    pathCandidate = `${Quickshell.env("HOME")}/${pathCandidate}`;

                if (pathCandidate.startsWith("Downloads/"))
                    pathCandidate = `${Quickshell.env("HOME")}/${pathCandidate}`;

                if (pathCandidate.startsWith("Videos/"))
                    pathCandidate = `${Quickshell.env("HOME")}/${pathCandidate}`;

                if (pathCandidate.startsWith("~/"))
                    pathCandidate = `${Quickshell.env("HOME")}/${pathCandidate.replace(/^~\//, "")}`;

            }
        }
        if (pathCandidate.startsWith("file://"))
            pathCandidate = pathCandidate.substring(7);

        if (pathCandidate.length > 0) {
            Quickshell.execDetached(["xdg-open", pathCandidate]);
            if (singleNotif.popup)
                Notifications.timeoutNotification(modelData.notificationId);

            return ;
        }

        // 3. Fallback: toggle expand view or dismiss popup
        if (singleNotif.popup)
            Notifications.timeoutNotification(modelData.notificationId);
        else
            singleNotif.expanded = !singleNotif.expanded;
    }

    function isMaterialIcon(name) {
        if (!name)
            return false;

        if (name.indexOf("ms:") === 0 || name.indexOf("material:") === 0)
            return true;

        const known = ["visibility", "eye", "remove_red_eye", "health_and_safety", "notifications"];
        return known.indexOf(name) !== -1;
    }

    Component.onCompleted: {
        if (singleNotif.popup)
            singleNotif.startTimeout();

    }
    radius: Math.max(4, Config.settings.borderRadius - 4)
    color: singleNotif.popup ? Colours.palette.surface : Qt.alpha(Colours.palette.surface_container_low, 0.6)
    implicitHeight: {
        let compact = Config.settings.notifications && Config.settings.notifications.compactMode;
        if (expanded) {
            if (areActions)
                return compact ? 130 : 150;
            else
                return compact ? 95 : 110;
        } else {
            return compact ? 54 : 80;
        }
    }
    implicitWidth: ListView.view ? ListView.view.width : 400
    width: ListView.view ? ListView.view.width : 400
    anchors.topMargin: 10

    Timer {
        id: dismissTimer

        interval: 1
        repeat: false
        onTriggered: {
            if (singleNotif.modelData)
                Notifications.timeoutNotification(singleNotif.modelData.notificationId);

        }
    }

    Timer {
        id: longPressTimer

        interval: 500
        repeat: false
        onTriggered: {
            if (modelData)
                Notifications.discardNotification(modelData.notificationId);

        }
    }

    MouseArea {
        property int startX
        property int startY

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        onPressed: (event) => {
            if (event.button === Qt.MiddleButton && modelData) {
                Notifications.discardNotification(modelData.notificationId);
                return ;
            }
            startX = event.x;
            startY = event.y;
            longPressTimer.restart();
        }
        onReleased: (event) => {
            if (longPressTimer.running) {
                longPressTimer.stop();
                handleSmartClick();
            }
        }
        onPositionChanged: (event) => {
            if (Math.abs(event.x - startX) > 10 || Math.abs(event.y - startY) > 10)
                longPressTimer.stop();

        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: Config.settings.borderRadius - 5

        Rectangle {
            id: iconImage

            property int size: 38

            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.preferredHeight: singleNotif.implicitHeight
            Layout.preferredWidth: size + 20
            color: Colours.palette.surface_container_low

            ClippingWrapperRectangle {
                visible: iconLoader.active && iconLoader.item
                  && iconLoader.item.status === Image.Ready
                radius: 1000
                height: iconImage.size
                width: iconImage.size
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: (parent.Layout.preferredHeight / 2) - (height / 2)
                anchors.leftMargin: (parent.Layout.preferredWidth / 2) - (width / 2)
                color: "transparent"

                Loader {
                    id: iconLoader

                    anchors.fill: parent
                    active: {
                        if (!singleNotif.modelData)
                            return false;

                        if (singleNotif.modelData.image)
                            return true;

                        let appIcon = singleNotif.modelData.appIcon;
                        if (appIcon && !singleNotif.isMaterialIcon(appIcon)) {
                            if (appIcon.indexOf("/") === 0 || appIcon.indexOf("file://") === 0)
                                return true;

                            if (Quickshell.iconPath(appIcon) !== "")
                                return true;

                        }
                        return false;
                    }

                    sourceComponent: IconImage {
                        id: iconRaw

                        source: {
                            if (!singleNotif.modelData)
                                return "";

                            if (singleNotif.modelData.image)
                                return Qt.resolvedUrl(singleNotif.modelData.image);

                            let appIcon = singleNotif.modelData.appIcon;
                            if (appIcon.indexOf("/") === 0 || appIcon.indexOf("file://") === 0)
                                return Qt.resolvedUrl(appIcon);

                            return Quickshell.iconPath(appIcon);
                        }
                        layer.enabled: (Config.settings && Config.settings.colours && Config.settings.colours.genType == "scheme-monochrome")

                        layer.effect: MultiEffect {
                            saturation: -1
                        }

                    }

                }

            }

            Text {
                visible: !iconLoader.active || !iconLoader.item || iconLoader.item.status !== Image.Ready
                anchors.centerIn: parent
                text: {
                    if (singleNotif.modelData && singleNotif.modelData.appIcon && singleNotif.modelData.appIcon.length > 0) {
                        let cleanIcon = singleNotif.modelData.appIcon.replace(/^(ms:|material:)/, "");
                        if (cleanIcon === "eye")
                            return "visibility";

                        return cleanIcon;
                    }
                    return "notifications";
                }
                font.family: (Config.settings && Config.settings.iconFont) ? Config.settings.iconFont : "Material Symbols Rounded"
                font.pixelSize: 22
                color: Qt.alpha(Colours.palette.on_surface, 0.7)
            }

        }

        Rectangle {
            id: textContent

            property int cWidth: Math.max(150, singleNotif.width - iconImage.size - (Config.settings.borderRadius * 2) - 10)
            property int padding: 10

            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            Layout.preferredHeight: {
                if (singleNotif.expanded) {
                    if (singleNotif.areActions)
                        return 110;
                    else
                        return 70;
                } else {
                    return 40;
                }
            }
            Layout.preferredWidth: cWidth
            color: "transparent"

            ColumnLayout {
                spacing: 3
                anchors.fill: parent

                Rectangle {
                    Layout.preferredHeight: (!singleNotif.modelData || singleNotif.modelData.body == "") ? 20 : 15
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    Layout.preferredWidth: textContent.cWidth - textContent.padding * 3
                    color: "transparent"

                    RowLayout {
                        spacing: 5

                        TextMetrics {
                            id: summaryElided

                            text: modelData ? modelData.summary : ""
                            font.family: Config.settings.font
                            elideWidth: Math.max(80, textContent.cWidth - 130)
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            text: summaryElided.elidedText
                            font.family: Config.settings.font
                            font.weight: 500
                            font.pixelSize: 14
                            color: Colours.palette.on_surface
                        }

                        Text {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            text: "·"
                            color: Colours.palette.on_surface
                            font.family: Config.settings.font
                            font.weight: 600
                            font.pixelSize: 11
                        }

                        Text {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            color: Colours.palette.outline
                            text: modelData ? NotificationUtils.getFriendlyNotifTimeString(modelData.time) : ""
                            font.family: Config.settings.font
                            font.weight: 600
                            font.pixelSize: 11
                        }

                    }

                }

                TextMetrics {
                    id: bodyElided

                    text: {
                        if (!modelData)
                            return "";

                        if (Config.settings.notifications && Config.settings.notifications.privacyMode && !singleNotif.expanded)
                            return "Notification content hidden";

                        return modelData.body;
                    }
                    font.family: Config.settings.font
                    elideWidth: Math.max(80, textContent.cWidth - textContent.padding)
                    elide: Text.ElideRight
                }

                Text {
                    Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                    text: bodyElided.elidedText
                    font.family: Config.settings.font
                    font.weight: 500
                    font.pixelSize: 11
                    visible: {
                        if (singleNotif.expanded)
                            return false;

                        if (!singleNotif.modelData || singleNotif.modelData.body == "")
                            return false;

                        return true;
                    }
                    color: Qt.alpha(Colours.palette.on_surface, 0.7)
                }

                ScrollView {
                    visible: singleNotif.expanded
                    Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                    implicitWidth: textContent.cWidth - 25
                    implicitHeight: singleNotif.expanded ? 40 : 10

                    Text {
                        width: textContent.cWidth - 30
                        height: 50
                        text: modelData ? modelData.body : ""
                        visible: singleNotif.expanded
                        wrapMode: Text.Wrap
                        font.family: Config.settings.font
                        font.weight: 500
                        font.pixelSize: 11
                        color: Qt.alpha(Colours.palette.on_surface, 0.7)
                    }

                    ScrollBar.horizontal: ScrollBar {
                        policy: ScrollBar.AlwaysOff
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AlwaysOff
                    }

                }

            }

            Rectangle {
                property bool hovered: false

                anchors.top: parent.top
                anchors.right: parent.right
                height: 25
                width: 25
                radius: 1000
                color: hovered ? Colours.palette.surface_container_highest : "transparent"
                visible: (modelData && bodyElided.elidedText == modelData.body) ? false : true

                Text {
                    anchors.centerIn: parent
                    text: "keyboard_arrow_up"
                    color: Colours.palette.on_surface
                    font.family: Config.settings.iconFont
                    font.weight: 600
                    font.pixelSize: 13
                    rotation: singleNotif.expanded ? 180 : 0
                    visible: parent.visible

                    Behavior on rotation {
                        PropertyAnimation {
                            duration: Config.settings.animationSpeed
                            easing.type: Easing.InSine
                        }

                    }

                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: parent.hovered = true
                    onExited: parent.hovered = false
                    onClicked: singleNotif.expanded = !singleNotif.expanded
                }

                Behavior on color {
                    PropertyAnimation {
                        duration: Config.settings.animationSpeed
                        easing.type: Easing.InSine
                    }

                }

            }

            Rectangle {
                id: actionsButtons

                anchors.bottom: parent.bottom
                width: textContent.cWidth - textContent.padding * 3
                height: 25
                visible: singleNotif.areActions && singleNotif.expanded
                color: "transparent"

                RowLayout {
                    spacing: 5

                    Repeater {
                        model: singleNotif.actions

                        delegate: Rectangle {
                            property bool hovered: false

                            Layout.preferredWidth: (actionsButtons.width / (singleNotif.actions ? Math.max(1, singleNotif.actions.length) : 1)) - 15
                            Layout.preferredHeight: 32
                            radius: hovered ? Config.settings.borderRadius : Config.settings.borderRadius - 5
                            color: {
                                if (hovered)
                                    return Qt.alpha(Colours.palette.surface_container_high, 0.7);
                                else
                                    return Colours.palette.surface_container_low;
                            }

                            Text {
                                anchors.centerIn: parent
                                text: modelData ? modelData.text : ""
                                color: parent.hovered ? Colours.palette.on_surface : Qt.alpha(Colours.palette.on_surface, 0.9)
                                font.family: Config.settings.font
                                font.pixelSize: 12

                                Behavior on color {
                                    PropertyAnimation {
                                        duration: Config.settings.animationSpeed
                                        easing.type: Easing.InSine
                                    }

                                }

                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: parent.hovered = true
                                onExited: parent.hovered = false
                                onClicked: {
                                    if (singleNotif.modelData && modelData)
                                        Notifications.attemptInvokeAction(singleNotif.modelData.notificationId, modelData.identifier);

                                }
                            }

                            Behavior on color {
                                PropertyAnimation {
                                    duration: Config.settings.animationSpeed
                                    easing.type: Easing.InSine
                                }

                            }

                            Behavior on radius {
                                PropertyAnimation {
                                    duration: Config.settings.animationSpeed
                                    easing.type: Easing.InSine
                                }

                            }

                        }

                    }

                }

            }

            Behavior on Layout.preferredHeight {
                PropertyAnimation {
                    duration: Config.settings.animationSpeed
                    easing.type: Easing.InSine
                }

            }

        }

    }

    Rectangle {
        id: timeoutBar

        height: 4
        width: singleNotif.popup ? parent.width : 0
        anchors.bottom: parent.bottom
        color: Colours.palette.surface_container_highest
        visible: Config.settings.notifications ? Config.settings.notifications.showTimeoutBar : true
    }

    NumberAnimation {
        id: timeoutShrink

        target: timeoutBar
        property: "width"
        to: 0
        duration: singleNotif.currentTime
        easing.type: Easing.Linear
    }

    Behavior on implicitHeight {
        PropertyAnimation {
            duration: Config.settings.animationSpeed
            easing.type: Easing.InSine
        }

    }

}
