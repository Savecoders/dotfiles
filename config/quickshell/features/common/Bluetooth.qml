import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property string textLabel: "Bluetooth Off"
    property string iconName: "bluetooth_disabled"

    signal stateChanged()

    function getBool() {
        if (!Bluetooth.defaultAdapter || Bluetooth.defaultAdapter.state <= BluetoothAdapterState.Disabled)
            return false;

        return Bluetooth.defaultAdapter.state === BluetoothAdapterState.Enabled;
    }

    function getIcon() {
        if (!Bluetooth.defaultAdapter || Bluetooth.defaultAdapter.state <= BluetoothAdapterState.Disabled) {
            textLabel = "Bluetooth Off";
            return "bluetooth_disabled";
        }
        const connectedDevices = Bluetooth.defaultAdapter.devices.values.filter((d) => {
            return d.connected;
        });
        if (Bluetooth.defaultAdapter.state === BluetoothAdapterState.Enabled && connectedDevices.length === 0) {
            textLabel = "Not Connected";
            return "bluetooth_searching";
        }
        if (connectedDevices.length === 1)
            textLabel = connectedDevices[0].name || "Connected";
        else
            textLabel = `${connectedDevices.length} Connections`;
        return "bluetooth";
    }

    function toggle() {
        if (Bluetooth.defaultAdapter) {
            const willEnable = !(Bluetooth.defaultAdapter.state === BluetoothAdapterState.Enabled);
            Bluetooth.defaultAdapter.enabled = willEnable;
            if (willEnable)
                Quickshell.execDetached(["bluetoothctl", "power", "on"]);
            else
                Quickshell.execDetached(["bluetoothctl", "power", "off"]);
        } else {
            Quickshell.execDetached(["rfkill", "toggle", "bluetooth"]);
        }
        refreshTimer.restart();
    }

    Connections {
        function onStateChanged() {
            root.iconName = root.getIcon();
            root.stateChanged();
        }

        target: Quickshell.Bluetooth.defaultAdapter
    }

    Timer {
        id: refreshTimer

        interval: 15000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            const newIcon = root.getIcon();
            if (newIcon !== root.iconName) {
                root.iconName = newIcon;
                root.stateChanged();
            }
        }
    }

}
