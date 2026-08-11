import QtQuick
import Quickshell
import Quickshell.Io
import qs.core
import qs.features
import qs.features.bar
import qs.features.dashboard
import qs.features.desktop
import qs.features.lockscreen
import qs.features.notificationslist
import qs.features.settings

Scope {
    Loader {
        active: Config.settings.componentControl.notifsIsEnabled

        sourceComponent: NotificationList {
        }

    }

    Loader {
        id: barHost

        property string lastPos: Config.settings.bar.position

        active: Config.settings.componentControl.barIsEnabled
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
        active: Config.settings.componentControl.dashboardIsEnabled

        sourceComponent: Dashboard {
            isDashboardOpen: IPCLoader.isDashboardOpen
        }

    }

    Loader {
        active: Config.settings.componentControl.lockscreenIsEnabled

        sourceComponent: Lockscreen {
        }

    }

    Loader {
        active: Config.settings.componentControl.desktopIsEnabled

        sourceComponent: Desktop {
        }

    }

    SettingsWindow {
        isSettingsWindowOpen: IPCLoader.isSettingsOpen
    }

    Loader {
        active: Config.settings.componentControl.notifsIsEnabled

        sourceComponent: NotificationCenterWindow {
            isNotificationsOpen: IPCLoader.isNotificationsOpen
        }

    }

}
