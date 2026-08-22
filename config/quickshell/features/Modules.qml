import QtQuick
import Quickshell
import Quickshell.Io
import qs.core
import qs.features
import qs.features.bar
import qs.features.common
import qs.features.dashboard
import qs.features.desktop
import qs.features.lockscreen
import qs.features.notificationslist
import qs.features.settings

Scope {
    BatteryPopup {
        isBatteryOpen: IPCLoader.isBatteryOpen
    }

    RecordingPopup {
        isRecordingOpen: IPCLoader.isRecordingOpen
    }

    Loader {
        active: Config.get("componentControl.notifsIsEnabled", true)

        sourceComponent: NotificationList {
        }

    }

    Loader {
        id: barHost

        property string lastPos: Config.barPosition

        active: Config.get("componentControl.barIsEnabled", true)
        onLastPosChanged: {
            if (active) {
                active = false;
                reloadTimer.restart();
            }
        }

        Timer {
            id: reloadTimer

            interval: 50
            repeat: false
            onTriggered: barHost.active = true
        }

        sourceComponent: Loader {
            active: IPCLoader.isBarOpen

            sourceComponent: Bar {
                onFinished: IPCLoader.toggleBar()
            }

        }

    }

    Loader {
        active: Config.get("componentControl.dashboardIsEnabled", true)

        sourceComponent: Dashboard {
            isDashboardOpen: IPCLoader.isDashboardOpen
        }

    }

    Loader {
        active: Config.get("componentControl.lockscreenIsEnabled", true)

        sourceComponent: Lockscreen {
        }

    }

    Loader {
        active: Config.get("componentControl.desktopIsEnabled", true)

        sourceComponent: Desktop {
        }

    }

    SettingsWindow {
        isSettingsWindowOpen: IPCLoader.isSettingsOpen
    }

    Loader {
        active: Config.get("componentControl.notifsIsEnabled", true)

        sourceComponent: NotificationCenterWindow {
            isNotificationsOpen: IPCLoader.isNotificationsOpen
        }

    }

}
