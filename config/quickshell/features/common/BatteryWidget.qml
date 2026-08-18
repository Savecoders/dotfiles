import QtQuick
import qs.core
import qs.features.common
import qs.services

ResourceWidget {
    id: root

    readonly property int batPercent: (Battery.percent !== undefined) ? Battery.percent : 100
    readonly property bool isCharging: !!Battery.charging

    tooltipText: "Battery: " + root.batPercent + "% (" + (root.isCharging ? (root.batPercent === 100 ? "Full" : "Charging") : "Discharging") + ")"
    progressValue: Math.max(0, Math.min(1, root.batPercent / 100))
    iconName: root.isCharging ? "battery_charging_full" : (root.batPercent <= 20 ? "battery_alert" : "battery_std")
    labelText: root.batPercent + "%"
    fgColor: {
        if (root.isCharging)
            return Accents.green;

        if (root.batPercent <= 20)
            return Colours.palette.error;

        return Colours.palette.primary;
    }
}
