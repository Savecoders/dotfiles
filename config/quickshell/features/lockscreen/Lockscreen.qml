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
            loader.item.locked = false;
        }
    }

    LazyLoader {
        id: loader

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

    IpcHandler {
        function lock() {
            loader.activeAsync = true;
        }

        function unlock() {
            loader.item.locked = false;
        }

        function isLocked() {
            return loader.active;
        }

        target: "lock"
    }

}
