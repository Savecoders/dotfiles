import QtQuick
import Quickshell
import qs.core
import qs.services
pragma Singleton

Singleton {
    id: root

    readonly property int percent: Power.percent
    readonly property bool charging: Power.charging
    readonly property real powerDrawWatts: Power.powerDrawWatts
    readonly property real capacityWh: Power.capacityWh
    readonly property int healthPercent: Power.healthPercent
    readonly property string activeProfile: Power.activeProfile

    function getBatteryColour(percent) {
        if (percent >= 40)
            return Accents.green;

        return Accents.red;
    }

}
