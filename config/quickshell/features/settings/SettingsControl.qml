import QtQuick
import Quickshell
import Quickshell.Io
import qs.core
import qs.services
pragma Singleton

Singleton {
    id: root

    property int settingsLocation: 0

    function setLocation(loc) {
        root.settingsLocation = loc;
    }

}
