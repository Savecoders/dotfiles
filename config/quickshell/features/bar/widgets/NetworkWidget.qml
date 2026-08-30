import QtQuick
import qs.core
import qs.features
import qs.features.common
import qs.services

ResourceWidget {
    id: root

    readonly property bool isConnected: Network.getBool()
    readonly property int strength: Network.signalStrength

    tooltipText: "Network: " + Network.textLabel + " (" + Network.connectionType + " • " + Network.stateName + ")" + (strength > 0 ? (" • " + strength + "%") : "")
    progressValue: strength > 0 ? (strength / 100) : (isConnected ? 1 : 0)
    iconName: Network.getIcon()
    labelText: Network.textLabel
    fgColor: isConnected ? Accents.blue : Colours.palette.on_surface_variant
    onClicked: {
        Tooltip.hide();
        IPCLoader.toggleDashboard();
    }
}
