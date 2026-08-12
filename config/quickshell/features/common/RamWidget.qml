import QtQuick
import qs.core
import qs.services

ResourceWidget {
    tooltipText: Ram.usedStr && Ram.totalStr ? ("RAM: " + Ram.usedStr + " / " + Ram.totalStr + " (" + (Ram.usage ?? 0) + "%)") : ("RAM: " + (Ram.usage ?? 0) + "%")
    progressValue: (Ram.usage ?? 0) / 100
    iconName: "memory"
    labelText: (Ram.usage ?? 0) + "%"
    fgColor: Colours.palette.primary
}
