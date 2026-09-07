import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs.core
import qs.features
import qs.services
pragma Singleton

Singleton {
    id: root

    // Configuration properties
    readonly property bool enabled: Config.get("idle.enabled", true)
    property bool keepAwake: Config.get("idle.keepAwake", false)
    readonly property bool lockBeforeSuspend: Config.get("idle.lockBeforeSuspend", true)
    readonly property bool fadeDimEnabled: Config.get("idle.fadeDimEnabled", true)
    // AC vs Battery detection
    readonly property bool isBatteryMode: !Power.charging && Power.status === "Discharging"
    // Timeouts in seconds
    readonly property int dimTimeout: isBatteryMode ? Config.get("idle.battery.dimTimeout", 120) : Config.get("idle.ac.dimTimeout", 300)
    readonly property int lockTimeout: isBatteryMode ? Config.get("idle.battery.lockTimeout", 300) : Config.get("idle.ac.lockTimeout", 600)
    readonly property int dpmsTimeout: isBatteryMode ? Config.get("idle.battery.dpmsTimeout", 360) : Config.get("idle.ac.dpmsTimeout", 900)
    readonly property int suspendTimeout: isBatteryMode ? Config.get("idle.battery.suspendTimeout", 600) : Config.get("idle.ac.suspendTimeout", 1800)
    // State tracking
    property bool isDimmed: false
    property int savedBrightness: 50
    property bool monitorsOff: false
    // External inhibition (e.g. keepAwake mode)
    readonly property bool isInhibited: keepAwake || !enabled

    function toggleKeepAwake() {
        setKeepAwake(!keepAwake);
    }

    function setKeepAwake(val) {
        keepAwake = val;
        Config.updateKey("idle.keepAwake", val);
    }

    function lock() {
        IPCLoader.isLockscreenOpen = true;
    }

    function suspend() {
        if (lockBeforeSuspend)
            lock();

        Quickshell.execDetached(["systemctl", "suspend"]);
    }

    function dimDisplay() {
        if (!fadeDimEnabled || isDimmed)
            return ;

        savedBrightness = Brightness.brightnessPercent;
        isDimmed = true;
        Brightness.setBrightnessPercent(Math.min(15, Brightness.brightnessPercent));
    }

    function restoreDisplay() {
        if (!isDimmed)
            return ;

        Brightness.setBrightnessPercent(savedBrightness > 0 ? savedBrightness : 50);
        isDimmed = false;
    }

    function turnOffDisplays() {
        if (monitorsOff)
            return ;

        monitorsOff = true;
        Hyprland.dispatch("dpms off");
    }

    function turnOnDisplays() {
        if (!monitorsOff)
            return ;

        monitorsOff = false;
        Hyprland.dispatch("dpms on");
    }

    function _rearm() {
        dimMonitor.enabled = false;
        lockMonitor.enabled = false;
        dpmsMonitor.enabled = false;
        suspendMonitor.enabled = false;
        Qt.callLater(_applyMonitors);
    }

    function _applyMonitors() {
        const canRun = enabled && !isInhibited;
        dimMonitor.enabled = canRun && dimTimeout > 0;
        lockMonitor.enabled = canRun && lockTimeout > 0;
        dpmsMonitor.enabled = canRun && dpmsTimeout > 0;
        suspendMonitor.enabled = canRun && suspendTimeout > 0;
    }

    onDimTimeoutChanged: _rearm()
    onLockTimeoutChanged: _rearm()
    onDpmsTimeoutChanged: _rearm()
    onSuspendTimeoutChanged: _rearm()
    onIsInhibitedChanged: _rearm()
    Component.onCompleted: {
        Qt.callLater(_applyMonitors);
    }

    // 1. Dim Monitor
    IdleMonitor {
        id: dimMonitor

        timeout: Math.max(1, root.dimTimeout)
        respectInhibitors: true
        enabled: false
        onIsIdleChanged: {
            if (!enabled)
                return ;

            if (isIdle)
                root.dimDisplay();
            else
                root.restoreDisplay();
        }
    }

    // 2. Lock Monitor
    IdleMonitor {
        id: lockMonitor

        timeout: Math.max(1, root.lockTimeout)
        respectInhibitors: true
        enabled: false
        onIsIdleChanged: {
            if (!enabled)
                return ;

            if (isIdle)
                root.lock();

        }
    }

    // 3. DPMS Monitor
    IdleMonitor {
        id: dpmsMonitor

        timeout: Math.max(1, root.dpmsTimeout)
        respectInhibitors: true
        enabled: false
        onIsIdleChanged: {
            if (!enabled)
                return ;

            if (isIdle) {
                root.turnOffDisplays();
            } else {
                root.turnOnDisplays();
                root.restoreDisplay();
            }
        }
    }

    // 4. Suspend Monitor
    IdleMonitor {
        id: suspendMonitor

        timeout: Math.max(1, root.suspendTimeout)
        respectInhibitors: true
        enabled: false
        onIsIdleChanged: {
            if (!enabled)
                return ;

            if (isIdle)
                root.suspend();

        }
    }

    // 5. Systemd Inhibitor (Process)
    Process {
        id: systemdInhibitor

        running: root.enabled && root.keepAwake
        command: ["systemd-inhibit", "--what=idle:sleep", "--who=Quickshell", "--why=Keep awake mode active", "--mode=block", "sleep", "infinity"]
    }

    // 6. DBus Sleep Watcher (PrepareForSleep)
    Process {
        id: sleepWatcher

        running: true
        command: ["dbus-monitor", "--system", "type='signal',sender='org.freedesktop.login1',member='PrepareForSleep'"]
        onExited: () => {
            sleepWatcher.running = true;
        }

        stdout: SplitParser {
            onRead: (line) => {
                if (line.indexOf("boolean true") >= 0) {
                    if (root.enabled && root.lockBeforeSuspend)
                        root.lock();

                } else if (line.indexOf("boolean false") >= 0) {
                    root.turnOnDisplays();
                    root.restoreDisplay();
                    Time.resync();
                }
            }
        }

    }

}
