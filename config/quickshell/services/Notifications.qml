pragma Singleton
import qs.features.common
import qs.core
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

/**
 * Provides extra features not in Quickshell.Services.Notifications:
 *  - Persistent storage
 *  - Popup notifications, with timeout
 *  - Notification groups by app
 */
Singleton {
    id: root

    readonly property int maxNotifications: 100
    property bool silent: false
    property var filePath: Directories.notificationsPath
    property var list: []
    property var popupList: list.filter((notif) => {
        return notif.popup;
    })
    property bool popupInhibited: Config.settings.notifications ? Config.settings.notifications.doNotDisturb : false
    property var latestTimeForApp: ({
    })
    property var groupsByAppName: groupsForList(root.list)
    property var popupGroupsByAppName: groupsForList(root.popupList)
    property var appNameList: appNameListForGroups(root.groupsByAppName)
    property var popupAppNameList: appNameListForGroups(root.popupGroupsByAppName)
    // Quickshell's notification IDs starts at 1 on each run, while saved notifications
    // can already contain higher IDs. This is for avoiding id collisions
    property int idOffset

    signal initDone()
    signal notify(var notification)
    signal discard(int id)
    signal discardAll()
    signal timeout(var id)

    function notifToJSON(notif) {
        return {
            "notificationId": notif.notificationId,
            "actions": notif.actions,
            "appIcon": notif.appIcon,
            "appName": notif.appName,
            "body": notif.body,
            "image": notif.image,
            "summary": notif.summary,
            "time": notif.time,
            "urgency": notif.urgency
        };
    }

    function notifToString(notif) {
        return JSON.stringify(notifToJSON(notif), null, 2);
    }

    function scheduleSave() {
        saveDebouncerTimer.restart();
    }

    function stringifyList(list) {
        return JSON.stringify(list.map((notif) => {
            return notifToJSON(notif);
        }), null, 2);
    }

    function toggleDND() {
        let current = Config.settings.notifications ? Config.settings.notifications.doNotDisturb : false;
        let nextVal = !current;
        Config.updateKey("notifications.doNotDisturb", nextVal);
        popupInhibited = nextVal;
    }

    function dummyInit() {
        console.log("[Notifications] Loaded server");
    }

    function appNameListForGroups(groups) {
        return Object.keys(groups).sort((a, b) => {
            // Sort by time, descending
            return groups[b].time - groups[a].time;
        });
    }

    function groupsForList(list) {
        const groups = {
        };
        list.forEach((notif) => {
            if (!groups[notif.appName])
                groups[notif.appName] = {
                "appName": notif.appName,
                "appIcon": notif.appIcon,
                "notifications": [],
                "time": 0
            };

            groups[notif.appName].notifications.push(notif);
            // Always set to the latest time in the group
            groups[notif.appName].time = latestTimeForApp[notif.appName] || notif.time;
        });
        return groups;
    }

    function destroyNotif(notif) {
        if (notif.timer) {
            notif.timer.destroy();
            notif.timer = null;
        }
        notif.destroy();
    }

    function discardNotification(id) {
        console.log("[Notifications] Discarding notification with ID: " + id);
        const index = root.list.findIndex((notif) => {
            return notif.notificationId === id;
        });
        const notifServerIndex = notifServer.trackedNotifications.values.findIndex((notif) => {
            return notif.id + root.idOffset === id;
        });
        if (index !== -1) {
            const notif = root.list[index];
            root.list = root.list.filter((_, i) => {
                return i !== index;
            });
            destroyNotif(notif);
            scheduleSave();
        }
        if (notifServerIndex !== -1)
            notifServer.trackedNotifications.values[notifServerIndex].dismiss();

        root.discard(id); // Emit signal
    }

    function discardAllNotifications() {
        root.list.forEach((notif) => {
            return destroyNotif(notif);
        });
        root.list = [];
        scheduleSave();
        notifServer.trackedNotifications.values.forEach((notif) => {
            notif.dismiss();
        });
        root.discardAll();
    }

    function cancelTimeout(id) {
        const index = root.list.findIndex((notif) => {
            return notif.notificationId === id;
        });
        if (root.list[index] != null)
            root.list[index].timer.stop();

    }

    function timeoutNotification(id) {
        const index = root.list.findIndex((notif) => {
            return notif.notificationId === id;
        });
        if (root.list[index] != null)
            root.list[index].popup = false;

        root.timeout(id);
    }

    function timeoutAll() {
        root.popupList.forEach((notif) => {
            root.timeout(notif.notificationId);
        });
        root.popupList.forEach((notif) => {
            notif.popup = false;
        });
    }

    function attemptInvokeAction(id, notifIdentifier) {
        console.log("[Notifications] Attempting to invoke action with identifier: " + notifIdentifier + " for notification ID: " + id);
        const notifServerIndex = notifServer.trackedNotifications.values.findIndex((notif) => {
            return notif.id + root.idOffset === id;
        });
        console.log("Notification server index: " + notifServerIndex);
        if (notifServerIndex !== -1) {
            const notifServerNotif = notifServer.trackedNotifications.values[notifServerIndex];
            const action = notifServerNotif.actions.find((action) => {
                return action.identifier === notifIdentifier;
            });
            console.log("Action found: " + JSON.stringify(action));
            action.invoke();
        } else {
            console.log("Notification not found in server: " + id);
        }
        root.discardNotification(id);
    }

    function playNotificationSound() {
        if (Config.settings.notifications && Config.settings.notifications.soundEnabled) {
            if (!notifSoundProc.running)
                notifSoundProc.running = true;

        }
    }

    function sendTestNotification() {
        Quickshell.execDetached(["notify-send", "Test Notification", "This is a demonstration of your notification popup settings in Quickshell."]);
    }

    function triggerListChange() {
        root.list = root.list.slice(0);
    }

    function refresh() {
        notifFileView.reload();
    }

    onListChanged: {
        // Update latest time for each app
        root.list.forEach((notif) => {
            if (!root.latestTimeForApp[notif.appName] || notif.time > root.latestTimeForApp[notif.appName])
                root.latestTimeForApp[notif.appName] = Math.max(root.latestTimeForApp[notif.appName] || 0, notif.time);

        });
        // Remove apps that no longer have notifications
        Object.keys(root.latestTimeForApp).forEach((appName) => {
            if (!root.list.some((notif) => {
                return notif.appName === appName;
            }))
                delete root.latestTimeForApp[appName];

        });
    }
    Component.onCompleted: {
        refresh();
    }

    Component {
        id: notifComponent

        Notif {
        }

    }

    Component {
        id: notifTimerComponent

        NotifTimer {
        }

    }

    Timer {
        id: saveDebouncerTimer

        interval: 2000
        repeat: false
        onTriggered: notifFileView.setText(stringifyList(root.list))
    }

    Timer {
        id: ttlTimer

        interval: 3.6e+06 // Every hour
        running: true
        repeat: true
        onTriggered: {
            const cutoff = Date.now() - 8.64e+07; // 24 hours
            const oldNotifs = root.list.filter((n) => {
                return n.time < cutoff;
            });
            if (oldNotifs.length > 0) {
                root.list = root.list.filter((n) => {
                    return n.time >= cutoff;
                });
                oldNotifs.forEach((n) => {
                    return destroyNotif(n);
                });
                saveDebouncerTimer.restart();
            }
        }
    }

    NotificationServer {
        id: notifServer

        // actionIconsSupported: true
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        bodySupported: true
        imageSupported: true
        keepOnReload: false
        persistenceSupported: true
        onNotification: (notification) => {
            notification.tracked = true;
            const newNotifObject = notifComponent.createObject(root, {
                "notificationId": notification.id + root.idOffset,
                "notification": notification,
                "time": Date.now()
            });
            root.list = [...root.list, newNotifObject];
            // Enforce max notifications limit
            while (root.list.length > root.maxNotifications) {
                const oldNotif = root.list.shift();
                destroyNotif(oldNotif);
            }
            // Popup
            if (!root.popupInhibited) {
                newNotifObject.popup = true;
                root.playNotificationSound();
                if (notification.expireTimeout != 0)
                    newNotifObject.timer = notifTimerComponent.createObject(root, {
                    "notificationId": newNotifObject.notificationId,
                    "interval": notification.expireTimeout < 0 ? (Config.settings.notifications.timeout ?? 7000) : notification.expireTimeout
                });

            }
            root.notify(newNotifObject);
            scheduleSave();
        }
    }

    Process {
        id: notifSoundProc

        command: ["paplay", Quickshell.shellDir + "/assets/break_notif.wav"]
    }

    FileView {
        // Notification actions are meaningless if they're not tracked by the server or the sender is dead

        id: notifFileView

        path: Qt.resolvedUrl(filePath)
        onLoaded: {
            const fileContents = notifFileView.text();
            root.list = JSON.parse(fileContents).map((notif) => {
                return notifComponent.createObject(root, {
                    "notificationId": notif.notificationId,
                    "actions": [],
                    "appIcon": notif.appIcon,
                    "appName": notif.appName,
                    "body": notif.body,
                    "image": notif.image,
                    "summary": notif.summary,
                    "time": notif.time,
                    "urgency": notif.urgency
                });
            });
            // Find largest notificationId
            let maxId = 0;
            root.list.forEach((notif) => {
                maxId = Math.max(maxId, notif.notificationId);
            });
            console.log("[Notifications] File loaded");
            root.idOffset = maxId;
            root.initDone();
        }
        onLoadFailed: (error) => {
            if (error == FileViewError.FileNotFound) {
                console.log("[Notifications] File not found, creating new file.");
                root.list = [];
                notifFileView.setText(stringifyList(root.list));
            } else {
                console.log("[Notifications] Error loading file: " + error);
            }
        }
    }

    component Notif: QtObject {
        id: wrapper

        required property int notificationId // Could just be `id` but it conflicts with the default prop in QtObject
        property Notification notification
        property var actions: (notification && notification.actions) ? notification.actions.map((action) => {
            return ({
                "identifier": action.identifier,
                "text": action.text
            });
        }) : []
        property bool popup: false
        property string appIcon: (notification && notification.appIcon) ? notification.appIcon : ""
        property string appName: (notification && notification.appName) ? notification.appName : ""
        property string body: (notification && notification.body) ? notification.body : ""
        property string image: (notification && notification.image) ? notification.image : ""
        property string summary: (notification && notification.summary) ? notification.summary : ""
        property double time
        property string urgency: (notification && notification.urgency) ? notification.urgency.toString() : "normal"
        property Timer timer

        onNotificationChanged: {
            if (notification === null)
                root.discardNotification(notificationId);

        }
    }

    component NotifTimer: Timer {
        required property int notificationId

        interval: 5000
        running: true
        onTriggered: () => {
            root.timeoutNotification(notificationId);
            destroy();
        }
    }

}
