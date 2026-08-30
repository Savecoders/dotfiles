import QtQuick
import qs.core
import qs.features
import qs.features.common
import qs.services

ResourceWidget {
    id: root

    readonly property int batPercent: (Power.percent !== undefined) ? Power.percent : 100
    readonly property bool isCharging: !!Power.charging

    tooltipText: "Battery: " + root.batPercent + "% (" + (root.isCharging ? (root.batPercent === 100 ? "Full" : "Charging") : "Discharging") + ")" + (Power.powerDrawWatts > 0 ? (" • " + Power.powerDrawWatts + " W") : "") + " • " + Power.activeProfile
    progressValue: Math.max(0, Math.min(1, root.batPercent / 100))
    iconName: Power.getBatteryIcon()
    labelText: root.batPercent + "%"
    fgColor: {
        if (root.isCharging)
            return Accents.green;

        if (root.batPercent <= 20)
            return Colours.palette.error;

        return Colours.palette.primary;
    }
    onClicked: {
        Tooltip.hide();
        IPCLoader.toggleBatteryAt(root);
    }
}
