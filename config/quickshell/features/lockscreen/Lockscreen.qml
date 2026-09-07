import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.features
import qs.features.lockscreen

Scope {
    LockContext {
        id: lockContext

        onUnlocked: {
            // Unlock the screen before exiting, or the compositor will display a
            // fallback lock you can't interact with.
            if (loader.item)
                loader.item.locked = false;

        }
    }

    LazyLoader {
        id: loader

        onActiveChanged: {
            if (!active)
                IPCLoader.isLockscreenOpen = false;

        }

        WlSessionLock {
            id: lock

            locked: true
            onLockedChanged: {
                if (!locked)
                    loader.active = false;

            }

            WlSessionLockSurface {
                LockSurface {
                    anchors.fill: parent
                    context: lockContext
                }

            }

        }

    }

    Connections {
        function onIsLockscreenOpenChanged() {
            if (IPCLoader.isLockscreenOpen) {
                loader.activeAsync = true;
            } else {
                if (loader.item)
                    loader.item.locked = false;

            }
        }

        target: IPCLoader
    }

    IpcHandler {
        function lock() {
            IPCLoader.isLockscreenOpen = true;
        }

        function unlock() {
            IPCLoader.isLockscreenOpen = false;
        }

        function isLocked() {
            return IPCLoader.isLockscreenOpen;
        }

        target: "lock"
    }

}
