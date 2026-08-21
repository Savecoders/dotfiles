import QtQuick
import Quickshell
import Quickshell.Io
import qs.core
pragma Singleton

Singleton {
    id: root

    property int percent: 100
    property bool charging: false
    property string status: "Full"
    property real powerDrawWatts: 0
    property real capacityWh: 0
    property int healthPercent: 100
    property string activeProfile: "balanced"
    property bool isPopupOpen: false

    function setProfile(profileName) {
        if (!profileName || profileName === "")
            return ;

        root.activeProfile = profileName;
        profileSetProc.command = ["powerprofilesctl", "set", profileName];
        profileSetProc.running = false;
        profileSetProc.running = true;
    }

    function refreshProfile() {
        profileGetProc.running = false;
        profileGetProc.running = true;
        refreshPowerDraw();
    }

    function togglePopup() {
        root.isPopupOpen = !root.isPopupOpen;
        if (root.isPopupOpen)
            refreshProfile();

    }

    function getBatteryIcon() {
        if (root.charging)
            return "battery_charging_full";

        if (root.percent <= 10)
            return "battery_alert";
        else if (root.percent <= 20)
            return "battery_1_bar";
        else if (root.percent <= 35)
            return "battery_2_bar";
        else if (root.percent <= 50)
            return "battery_3_bar";
        else if (root.percent <= 65)
            return "battery_4_bar";
        else if (root.percent <= 80)
            return "battery_5_bar";
        else if (root.percent <= 95)
            return "battery_6_bar";
        else
            return "battery_full";
    }

    function updateHealth() {
        const full = parseInt(String(batEnergyFull.text()).trim(), 10);
        const design = parseInt(String(batEnergyDesign.text()).trim(), 10);
        if (!isNaN(full) && full > 0) {
            root.capacityWh = Math.round((full / 1e+06) * 10) / 10;
            if (!isNaN(design) && design > 0)
                root.healthPercent = Math.min(100, Math.round((full / design) * 100));

        }
    }

    function refreshPowerDraw() {
        powerNowProc.running = false;
        powerNowProc.running = true;
    }

    Component.onCompleted: {
        const capText = String(batCapacity.text()).trim();
        const val = parseInt(capText, 10);
        if (!isNaN(val))
            root.percent = val;

        const st = String(batStatus.text()).trim();
        root.status = st;
        root.charging = (st === "Charging" || st === "Full");
        updateHealth();
        refreshProfile();
    }

    FileView {
        id: batCapacity

        path: "/sys/class/power_supply/BAT0/capacity"
        watchChanges: true
        onLoadFailed: () => {
        }
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
        onLoadFailed: () => {
        }
        onTextChanged: {
            const st = String(text()).trim();
            root.status = st;
            root.charging = (st === "Charging" || st === "Full");
            root.refreshPowerDraw();
        }
    }

    Process {
        id: powerNowProc

        running: false
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT0/power_now 2>/dev/null || echo 0"]

        stdout: SplitParser {
            onRead: (data) => {
                const val = parseFloat(String(data).trim());
                if (!isNaN(val) && val > 0)
                    root.powerDrawWatts = Math.round((val / 1e+06) * 10) / 10;
                else
                    root.powerDrawWatts = 0;
            }
        }

    }

    FileView {
        id: batEnergyFull

        path: "/sys/class/power_supply/BAT0/energy_full"
        watchChanges: true
        onLoadFailed: () => {
        }
        onTextChanged: root.updateHealth()
    }

    FileView {
        id: batEnergyDesign

        path: "/sys/class/power_supply/BAT0/energy_full_design"
        watchChanges: true
        onLoadFailed: () => {
        }
        onTextChanged: root.updateHealth()
    }

    Process {
        id: profileGetProc

        running: true
        command: ["powerprofilesctl", "get"]

        stdout: SplitParser {
            onRead: (data) => {
                const p = String(data).trim();
                if (p.length > 0)
                    root.activeProfile = p;

            }
        }

    }

    Process {
        id: profileSetProc

        running: false
        onExited: (exitCode) => {
            if (exitCode === 0)
                root.refreshProfile();

        }
    }

}
