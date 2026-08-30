import QtQuick
import qs.core
import qs.features
import qs.services

BarIconButton {
    id: root

    collapsible: false
    iconGlyph: Notifications.list.length !== 0 ? "notifications_unread" : "notifications"
    tooltipText: Notifications.list.length !== 0 ? (Notifications.list.length + " Notifications") : "No notifications"
    onActivated: IPCLoader.toggleNotifications()
}
