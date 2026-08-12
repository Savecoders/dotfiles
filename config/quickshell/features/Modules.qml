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
        active: (Config.settings && Config.settings.componentControl && Config.settings.componentControl.notifsIsEnabled !== undefined) ? Config.settings.componentControl.notifsIsEnabled : true

        sourceComponent: NotificationList {
        }

    }

    Loader {
        id: barHost

        property string lastPos: (Config.settings && Config.settings.bar && Config.settings.bar.position) ? Config.settings.bar.position : "top"

        active: (Config.settings && Config.settings.componentControl && Config.settings.componentControl.barIsEnabled !== undefined) ? Config.settings.componentControl.barIsEnabled : true
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
        active: (Config.settings && Config.settings.componentControl && Config.settings.componentControl.dashboardIsEnabled !== undefined) ? Config.settings.componentControl.dashboardIsEnabled : true

        sourceComponent: Dashboard {
            isDashboardOpen: IPCLoader.isDashboardOpen
        }

    }

    Loader {
        active: (Config.settings && Config.settings.componentControl && Config.settings.componentControl.lockscreenIsEnabled !== undefined) ? Config.settings.componentControl.lockscreenIsEnabled : true

        sourceComponent: Lockscreen {
        }

    }

    Loader {
        active: (Config.settings && Config.settings.componentControl && Config.settings.componentControl.desktopIsEnabled !== undefined) ? Config.settings.componentControl.desktopIsEnabled : true

        sourceComponent: Desktop {
        }

    }

    SettingsWindow {
        isSettingsWindowOpen: IPCLoader.isSettingsOpen
    }

    Loader {
        active: (Config.settings && Config.settings.componentControl && Config.settings.componentControl.notifsIsEnabled !== undefined) ? Config.settings.componentControl.notifsIsEnabled : true

        sourceComponent: NotificationCenterWindow {
            isNotificationsOpen: IPCLoader.isNotificationsOpen
        }

    }

}
