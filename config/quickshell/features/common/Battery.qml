import QtQuick
import Quickshell
import Quickshell.Io
import qs.core
pragma Singleton

Singleton {
    id: root

    property int percent: 100
    property bool charging: false

    function getBatteryColour(percent) {
        if (percent >= 40)
            return Accents.green;

        return Accents.red;
    }

    Component.onCompleted: {
        const capText = String(batCapacity.text()).trim();
        const val = parseInt(capText, 10);
        if (!isNaN(val))
            root.percent = val;

        const status = String(batStatus.text()).trim();
        root.charging = (status === "Charging" || status === "Full");
    }

    FileView {
        id: batCapacity

        path: "/sys/class/power_supply/BAT0/capacity"
        watchChanges: true
        onTextChanged: {
            const val = parseInt(String(text()).trim(), 10);
            if (!isNaN(val))
                root.percent = val;

        }
    }

    FileView {
        id: batStatus

        path: "/sys/class/power_supply/BAT0/status"
        watchChanges: true
        onTextChanged: {
            const status = String(text()).trim();
            root.charging = (status === "Charging" || status === "Full");
        }
    }

}
