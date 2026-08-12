import QtQuick
import qs.core
import qs.services

ResourceWidget {
    tooltipText: "Package Temp: " + (Thermal.temp ?? 0) + "°C"
    progressValue: Math.max(0, Math.min(1, ((Thermal.temp ?? 25) - 25) / (90 - 25)))
    iconName: "device_thermostat"
    labelText: (Thermal.temp ?? 0) + "°C"
    fgColor: (Thermal.temp ?? 0) > 75 ? Colours.palette.error : Colours.palette.primary
}
