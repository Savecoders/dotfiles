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
        if (!profileGetProc.running)
            profileGetProc.running = true;

    }

    function togglePopup() {
        root.isPopupOpen = !root.isPopupOpen;
        if (root.isPopupOpen)
            refreshAll();

    }

    function getBatteryIcon() {
        if (root.charging)
            return "battery_android_bolt";

        if (root.percent <= 10)
            return "battery_android_alert";
        else if (root.percent <= 20)
            return "battery_android_1";
        else if (root.percent <= 35)
            return "battery_android_2";
        else if (root.percent <= 50)
            return "battery_android_3";
        else if (root.percent <= 65)
            return "battery_android_4";
        else if (root.percent <= 80)
            return "battery_android_5";
        else if (root.percent <= 95)
            return "battery_android_6";
        else
            return "battery_android_full";
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
        if (!powerNowProc.running)
            powerNowProc.running = true;

    }

    function refreshAll() {
        batCapacity.reload();
        const capText = String(batCapacity.text()).trim();
        const val = parseInt(capText, 10);
        if (!isNaN(val))
            root.percent = val;

        batStatus.reload();
        const st = String(batStatus.text()).trim();
        if (st.length > 0) {
            root.status = st;
            root.charging = (st === "Charging" || st === "Full");
        }
        batEnergyFull.reload();
        batEnergyDesign.reload();
        updateHealth();
        refreshPowerDraw();
        refreshProfile();
    }

    Timer {
        id: pollTimer

        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshAll()
    }

    FileView {
        id: batCapacity

        path: "/sys/class/power_supply/BAT0/capacity"
        onLoadFailed: () => {
        }
    }

    FileView {
        id: batStatus

        path: "/sys/class/power_supply/BAT0/status"
        onLoadFailed: () => {
        }
    }

    Process {
        id: powerNowProc

        running: false
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT0/power_now 2>/dev/null || (c=$(cat /sys/class/power_supply/BAT0/current_now 2>/dev/null) && v=$(cat /sys/class/power_supply/BAT0/voltage_now 2>/dev/null) && [ -n \"$c\" ] && [ -n \"$v\" ] && awk -v c=\"$c\" -v v=\"$v\" 'BEGIN { print (c*v)/1000000000000 }') || echo 0"]

        stdout: SplitParser {
            onRead: (data) => {
                const val = parseFloat(String(data).trim());
                if (!isNaN(val) && val > 0) {
                    if (val > 1000)
                        root.powerDrawWatts = Math.round((val / 1e+06) * 10) / 10;
                    else
                        root.powerDrawWatts = Math.round(val * 10) / 10;
                } else {
                    root.powerDrawWatts = 0;
                }
            }
        }

    }

    FileView {
        id: batEnergyFull

        path: "/sys/class/power_supply/BAT0/energy_full"
        onLoadFailed: () => {
        }
    }

    FileView {
        id: batEnergyDesign

        path: "/sys/class/power_supply/BAT0/energy_full_design"
        onLoadFailed: () => {
        }
    }

    Process {
        id: profileGetProc

        running: false
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
