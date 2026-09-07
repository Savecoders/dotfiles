//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma UseQApplication
//@ pragma Env QT_SCALE_FACTOR=1
//@ pragma IconTheme Papirus

import QtQuick
import Quickshell
import qs.core
import qs.features
import qs.services

ShellRoot {
    id: shellRoot

    Component.onCompleted: {
        Qt.callLater(() => {
            Notifications.dummyInit();
            EyeProtection;
            Ipc;
            Idle;
        });
        deferredInitTimer.start();
    }

    FontLoader {
        id: iconFontLoader

        source: Qt.resolvedUrl(Quickshell.shellDir + "/assets/fonts/MaterialSymbolsRounded.ttf")
    }

    Timer {
        id: deferredInitTimer

        interval: 2000
        repeat: false
        onTriggered: {
            if (Config.settings.nightmodeOnStartup)
                Nightmode.turnOn();
            else
                Nightmode.turnOff();
        }
    }

    LazyLoader {
        source: Contracts.powermenu.source
        active: Contracts.powermenu.active && Globals.visibility.powermenu
    }

    LazyLoader {
        source: Contracts.overlays.source
        active: Contracts.overlays.active && Config.settings.overlays.enabled
    }

    Modules {
    }

}
