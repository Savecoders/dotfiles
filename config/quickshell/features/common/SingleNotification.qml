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

    function extractPathOrUrl(raw) {
        if (!raw || typeof raw !== "string")
            return "";

        let str = raw.trim();
        if (str.startsWith("http://") || str.startsWith("https://"))
            return str;

        if (str.startsWith("image://icon/"))
            str = str.replace(/^image:\/\/icon\/\/?/, "/");

        if (str.startsWith("file://"))
            str = str.substring(7);

        if (str.startsWith("~/"))
            str = (Quickshell.env("HOME") || "") + str.substring(1);

        if (str.startsWith("Pictures/") || str.startsWith("Downloads/") || str.startsWith("Videos/"))
            str = (Quickshell.env("HOME") || "") + "/" + str;

        if (str.startsWith("/"))
            return str;

        return "";
    }

    function getValidNotificationPath() {
        if (!modelData)
            return "";

        // 1. Check modelData.image
        let p = extractPathOrUrl(modelData.image);
        if (p && p.length > 0 && (p.includes("/") || p.includes(".")))
            return p;

        // 2. Check modelData.appIcon
        p = extractPathOrUrl(modelData.appIcon);
        if (p && p.length > 0 && (p.includes("/") || p.includes(".")))
            return p;

        // 3. Check URLs or file paths in modelData.body
        if (modelData.body && modelData.body.length > 0) {
            let urlMatch = modelData.body.match(/https?:\/\/[^\s'"\(\)]+/);
            if (urlMatch && urlMatch[0])
                return urlMatch[0];

            let fileMatch = modelData.body.match(/(\/(?:[^\s'"\(\)]+)|~\/(?:[^\s'"\(\)]+)|Pictures\/(?:[^\s'"\(\)]+)|Downloads\/(?:[^\s'"\(\)]+)|Videos\/(?:[^\s'"\(\)]+))/);
            if (fileMatch && fileMatch[1]) {
                p = extractPathOrUrl(fileMatch[1]);
                if (p && p.length > 0)
                    return p;

            }
        }
        // 4. Check URLs in modelData.summary
        if (modelData.summary && modelData.summary.length > 0) {
            let urlMatch = modelData.summary.match(/https?:\/\/[^\s'"\(\)]+/);
            if (urlMatch && urlMatch[0])
                return urlMatch[0];

        }
        return "";
    }

    function resolveImageSource(img, icon) {
        if (img && img.length > 0) {
            if (img.startsWith("image://") || img.startsWith("http://") || img.startsWith("https://") || img.startsWith("file://"))
                return img;

            if (img.startsWith("~/"))
                return "file://" + (Quickshell.env("HOME") || "") + img.substring(1);

            if (img.startsWith("/"))
                return "file://" + img;

            return img;
        }
        if (icon && icon.length > 0) {
            if (icon.startsWith("image://") || icon.startsWith("file://"))
                return icon;

            if (icon.startsWith("~/"))
                return "file://" + (Quickshell.env("HOME") || "") + icon.substring(1);

            if (icon.startsWith("/"))
                return "file://" + icon;

            return Quickshell.iconPath(icon);
        }
        return "";
    }

    function handleSmartClick() {
        if (!modelData)
            return ;

        // Invoke default action if provided by client app
        if (modelData.actions && modelData.actions.length > 0) {
            let defAction = modelData.actions.find((a) => {
                return a.identifier === "default";
            }) || modelData.actions[0];
            if (defAction) {
                Notifications.attemptInvokeAction(modelData.notificationId, defAction.identifier);
                return ;
            }
        }
        // Open file/image/URL target via default system application handler
        let pathCandidate = getValidNotificationPath();
        if (pathCandidate && pathCandidate.length > 0) {
            Quickshell.execDetached(["xdg-open", pathCandidate]);
            if (singleNotif.popup)
                Notifications.timeoutNotification(modelData.notificationId);

            return ;
        }
        // Fallback: toggle expand view or dismiss popup
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
    radius: Config.get("borderRadius", 20)
    color: singleNotif.popup ? Colours.palette.surface_container : Qt.alpha(Colours.palette.surface_container_low, 0.7)
    border.color: Qt.alpha(Colours.palette.outline, 0.15)
    border.width: 1
    implicitWidth: ListView.view ? ListView.view.width : 400
    width: ListView.view ? ListView.view.width : 400
    implicitHeight: {
        let compact = Config.get("notifications.compactMode", false);
        if (expanded) {
            if (areActions)
                return compact ? 130 : 150;
            else
                return compact ? 95 : 110;
        } else {
            return compact ? 56 : 74;
        }
    }

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
        spacing: Styling.spacing.none

        StyledRect {
            id: iconPanel

            property int iconSize: 38

            variant: "internalbg"
            useDefaultRadius: false
            border.width: 0
            Layout.fillHeight: true
            Layout.preferredWidth: iconSize + 22
            color: Colours.palette.surface_container_low

            ClippingWrapperRectangle {
                anchors.centerIn: parent
                radius: Styling.radius.full
                width: iconPanel.iconSize
                height: iconPanel.iconSize
                color: "transparent"
                visible: iconLoader.active && iconLoader.item && iconLoader.item.status === Image.Ready

                Loader {
                    id: iconLoader

                    anchors.fill: parent
                    active: {
                        if (!singleNotif.modelData)
                            return false;

                        if (singleNotif.modelData.image && singleNotif.modelData.image.length > 0)
                            return true;

                        let appIcon = singleNotif.modelData.appIcon;
                        if (appIcon && !singleNotif.isMaterialIcon(appIcon)) {
                            if (appIcon.indexOf("/") === 0 || appIcon.indexOf("file://") === 0 || appIcon.indexOf("image://") === 0)
                                return true;

                            if (Quickshell.iconPath(appIcon) !== "")
                                return true;

                        }
                        return false;
                    }
                    sourceComponent: {
                        let src = singleNotif.modelData ? singleNotif.resolveImageSource(singleNotif.modelData.image, singleNotif.modelData.appIcon) : "";
                        if (src.indexOf("file://") === 0 || src.indexOf("/") === 0 || src.indexOf("http://") === 0 || src.indexOf("https://") === 0)
                            return fileImageComponent;

                        return themeIconComponent;
                    }
                }

                Component {
                    id: fileImageComponent

                    Image {
                        source: singleNotif.modelData ? singleNotif.resolveImageSource(singleNotif.modelData.image, singleNotif.modelData.appIcon) : ""
                        sourceSize: Qt.size(iconPanel.iconSize, iconPanel.iconSize)
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: false
                        layer.enabled: Config.get("colours.genType", "") === "scheme-monochrome"

                        layer.effect: MultiEffect {
                            saturation: -1
                        }

                    }

                }

                Component {
                    id: themeIconComponent

                    IconImage {
                        source: singleNotif.modelData ? singleNotif.resolveImageSource(singleNotif.modelData.image, singleNotif.modelData.appIcon) : ""
                        layer.enabled: Config.get("colours.genType", "") === "scheme-monochrome"

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
                font.family: Config.get("iconFont", "Material Symbols Rounded")
                font.pixelSize: Styling.fontSize.xl
                color: Qt.alpha(Colours.palette.on_surface, 0.8)
            }

        }

        // Right Content Area
        Item {
            id: textContent

            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Styling.spacing.xxl
                spacing: Styling.spacing.sm

                // Header Row: Summary on Left + Timestamp pinned to Far Right
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Styling.spacing.lg

                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                        text: modelData ? modelData.summary : ""
                        font.family: Config.settings.font ?? "SF Pro Display"
                        font.weight: Font.DemiBold
                        font.pixelSize: Styling.fontSize.body
                        color: Colours.palette.on_surface
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        text: modelData ? NotificationUtils.getFriendlyNotifTimeString(modelData.time) : ""
                        font.family: Config.settings.font ?? "SF Pro Display"
                        font.weight: Font.Normal
                        font.pixelSize: Styling.fontSize.sm
                        color: Colours.palette.outline
                    }

                    // Expand/Collapse toggle button
                    StyledRect {
                        id: expandBtn

                        property bool hovered: false

                        variant: "internalbg"
                        useDefaultRadius: false
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        radius: Styling.spacing.sm
                        color: hovered ? Colours.palette.surface_container_highest : "transparent"
                        visible: !!(modelData && modelData.body && modelData.body.length > 40)

                        Text {
                            anchors.centerIn: parent
                            text: "keyboard_arrow_up"
                            color: Colours.palette.on_surface
                            font.family: Config.get("iconFont", "Material Symbols Rounded")
                            font.pixelSize: Styling.fontSize.bodyLarge
                            rotation: singleNotif.expanded ? 180 : 0

                            Behavior on rotation {
                                PropertyAnimation {
                                    duration: Config.get("animationSpeed", 200)
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

                    }

                }

                // Body Text
                Text {
                    id: bodyText

                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                    text: {
                        if (!modelData || !modelData.body)
                            return "";

                        if (Config.get("notifications.privacyMode", false) && !singleNotif.expanded)
                            return "Notification content hidden";

                        return modelData.body;
                    }
                    font.family: Config.get("font", "SF Pro Display")
                    font.weight: Font.Light
                    font.pixelSize: Styling.fontSize.md
                    color: Qt.alpha(Colours.palette.on_surface, 0.7)
                    wrapMode: singleNotif.expanded ? Text.Wrap : Text.NoWrap
                    elide: singleNotif.expanded ? Text.ElideNone : Text.ElideRight
                    visible: !!(modelData && modelData.body && modelData.body.length > 0)
                    maximumLineCount: singleNotif.expanded ? 10 : 2
                }

                // Action Buttons Row
                RowLayout {
                    id: actionsRow

                    Layout.fillWidth: true
                    Layout.topMargin: Styling.spacing.sm
                    visible: singleNotif.areActions && singleNotif.expanded
                    spacing: Styling.spacing.lg

                    Repeater {
                        model: singleNotif.actions

                        delegate: StyledRect {
                            property bool hovered: false

                            variant: "internalbg"
                            useDefaultRadius: false
                            border.width: 0
                            Layout.fillWidth: true
                            Layout.preferredHeight: 28
                            radius: Math.max(4, Config.get("borderRadius", 8) - 4)
                            color: hovered ? Colours.palette.primary : Colours.palette.surface_container_high

                            Text {
                                anchors.centerIn: parent
                                text: modelData ? modelData.text : ""
                                color: parent.hovered ? Colours.palette.on_primary : Colours.palette.on_surface
                                font.family: Config.get("font", "SF Pro Display")
                                font.pixelSize: Styling.fontSize.sm
                                font.weight: Font.Medium
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

                        }

                    }

                }

            }

        }

    }

    // Timeout progress bar at bottom of card
    StyledRect {
        id: timeoutBar

        variant: "focus"
        useDefaultRadius: false
        border.width: 0
        height: Styling.radius.xs
        width: singleNotif.popup ? parent.width : 0
        anchors.bottom: parent.bottom
        color: Colours.palette.primary
        opacity: 0.8
        visible: singleNotif.popup && Config.get("notifications.showTimeoutBar", true)
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
            duration: Config.get("animationSpeed", 200)
            easing.type: Easing.InSine
        }

    }

}
