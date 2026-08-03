import QtQuick
import Quickshell
pragma Singleton

Singleton {
    id: root

    property string notificationsPath: Quickshell.shellDir + "/cache/notifications.json"
    property string coverArt: Quickshell.shellDir + "/cache/coverArt"
    property string shellConfigPath: Quickshell.shellDir + "/settings/settings.json"
    property string scriptsPath: Quickshell.shellDir + "/scripts"
    property string defaultsPath: Quickshell.shellDir + "/assets"
}
