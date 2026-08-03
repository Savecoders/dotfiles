pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland

Singleton {
    id: root

    readonly property bool isHyprland: Compositor.require("hyprland")
    readonly property var toplevels: isHyprland ? Hyprland.toplevels : []
    readonly property var workspaces: isHyprland ? Hyprland.workspaces : []
    readonly property var monitors: isHyprland ? Hyprland.monitors : []
    readonly property Toplevel activeToplevel: isHyprland ? ToplevelManager.activeToplevel : null
    readonly property HyprlandWorkspace focusedWorkspace: isHyprland ? Hyprland.focusedWorkspace : null
    readonly property HyprlandMonitor focusedMonitor: isHyprland ? Hyprland.focusedMonitor : null
    readonly property int focusedWorkspaceId: (focusedWorkspace && focusedWorkspace.id !== undefined) ? focusedWorkspace.id : 1
    property real screenW: focusedMonitor ? focusedMonitor.width : 0
    property real screenH: focusedMonitor ? focusedMonitor.height : 0
    property real screenScale: focusedMonitor ? focusedMonitor.scale : 1
    // Parsed hyprctl data
    property var windowList: []
    property var windowByAddress: ({
    })
    property var addresses: []
    property var layers: ({
    })
    property var monitorsInfo: []
    property var workspacesInfo: []
    property var workspaceById: ({
    })
    property var workspaceIds: []
    property var activeWorkspaceInfo: null
    property string keyboardLayout: "?"
    property bool isNewHyprland: false
    property var _focusedWindowCache: ({
    })
    property bool _updating: false

    signal stateChanged()

    function dispatch(request) {
        if (!isHyprland)
            return ;

        Hyprland.dispatch(request);
    }

    function changeWorkspace(targetWorkspaceId) {
        if (!isHyprland || !targetWorkspaceId)
            return ;

        if (root.isNewHyprland)
            root.dispatch("hl.dsp.focus({ workspace = " + targetWorkspaceId + " })");
        else
            root.dispatch("workspace " + targetWorkspaceId);
    }

    function focusedWindowForWorkspace(workspaceId) {
        if (!isHyprland)
            return null;

        if (_focusedWindowCache[workspaceId] !== undefined)
            return _focusedWindowCache[workspaceId];

        const wsWindows = root.windowList.filter((w) => {
            return w.workspace && w.workspace.id === workspaceId;
        });
        if (wsWindows.length === 0) {
            _focusedWindowCache[workspaceId] = null;
            return null;
        }
        const res = wsWindows.reduce((best, win) => {
            const bestFocus = (best && best.focusHistoryID !== undefined) ? best.focusHistoryID : Infinity;
            const winFocus = (win && win.focusHistoryID !== undefined) ? win.focusHistoryID : Infinity;
            return winFocus < bestFocus ? win : best;
        }, null);
        _focusedWindowCache[workspaceId] = res;
        return res;
    }

    function isWorkspaceOccupied(id) {
        if (!isHyprland)
            return false;

        const ws = Hyprland.workspaces.values.find((w) => {
            return w && w.id === id;
        });
        return (ws && ws.lastIpcObject && ws.lastIpcObject.windows > 0) ? true : false;
    }

    function updateAll() {
        if (!isHyprland || _updating)
            return ;

        _updating = true;
        getClients.running = true;
        getLayers.running = true;
        getMonitors.running = true;
        getWorkspaces.running = true;
        getActiveWorkspace.running = true;
    }

    function onProcFinished() {
        if (!getClients.running && !getLayers.running && !getMonitors.running && !getWorkspaces.running && !getActiveWorkspace.running)
            _updating = false;

    }

    function refreshKeyboardLayout() {
        if (!isHyprland)
            return ;

        hyprctlDevices.running = true;
    }

    onWindowListChanged: _focusedWindowCache = ({
    })
    Component.onCompleted: {
        if (isHyprland) {
            updateAll();
            refreshKeyboardLayout();
        }
    }

    Process {
        id: checkVersion

        running: isHyprland
        command: ["hyprctl", "version"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const match = this.text.match(/Hyprland\s+(\d+)\.(\d+)\.(\d+)/);
                    if (match) {
                        const major = parseInt(match[1]);
                        const minor = parseInt(match[2]);
                        if (major > 0 || minor >= 55)
                            root.isNewHyprland = true;

                    }
                } catch (e) {
                    console.error("Failed to parse hyprctl version:", e);
                }
            }
        }

    }

    Process {
        id: hyprctlDevices

        running: false
        command: ["hyprctl", "devices", "-j"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const devices = JSON.parse(this.text);
                    const keyboard = devices.keyboards.find((k) => {
                        return k.main;
                    }) || devices.keyboards[0];
                    let layout = (keyboard && keyboard.active_keymap) ? keyboard.active_keymap.toUpperCase().slice(0, 2) : "?";
                    Qt.callLater(() => {
                        root.keyboardLayout = layout;
                    });
                } catch (err) {
                    Qt.callLater(() => {
                        root.keyboardLayout = "?";
                    });
                }
            }
        }

    }

    Process {
        id: getClients

        running: false
        command: ["hyprctl", "clients", "-j"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(this.text);
                    let tempWinByAddress = {};
                    for (let win of parsed) tempWinByAddress[win.address] = win;
                    let addrs = parsed.map((w) => w.address);
                    Qt.callLater(() => {
                        root.windowList = parsed;
                        root.windowByAddress = tempWinByAddress;
                        root.addresses = addrs;
                    });
                } catch (e) {
                    console.error("Failed to parse clients:", e);
                }
                Qt.callLater(() => root.onProcFinished());
            }
        }

    }

    Process {
        id: getMonitors

        running: false
        command: ["hyprctl", "monitors", "-j"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(this.text);
                    Qt.callLater(() => {
                        root.monitorsInfo = parsed;
                    });
                } catch (e) {
                    console.error("Failed to parse monitors:", e);
                }
                Qt.callLater(() => root.onProcFinished());
            }
        }

    }

    Process {
        id: getLayers

        running: false
        command: ["hyprctl", "layers", "-j"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(this.text);
                    Qt.callLater(() => {
                        root.layers = parsed;
                    });
                } catch (e) {
                    console.error("Failed to parse layers:", e);
                }
                Qt.callLater(() => root.onProcFinished());
            }
        }

    }

    Process {
        id: getWorkspaces

        running: false
        command: ["hyprctl", "workspaces", "-j"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(this.text);
                    let map = {};
                    for (let ws of parsed) map[ws.id] = ws;
                    let wsIds = parsed.map((ws) => ws.id);
                    Qt.callLater(() => {
                        root.workspacesInfo = parsed;
                        root.workspaceById = map;
                        root.workspaceIds = wsIds;
                    });
                } catch (e) {
                    console.error("Failed to parse workspaces:", e);
                }
                Qt.callLater(() => root.onProcFinished());
            }
        }

    }

    Process {
        id: getActiveWorkspace

        running: false
        command: ["hyprctl", "activeworkspace", "-j"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(this.text);
                    Qt.callLater(() => {
                        root.activeWorkspaceInfo = parsed;
                    });
                } catch (e) {
                    console.error("Failed to parse active workspace:", e);
                }
                Qt.callLater(() => root.onProcFinished());
            }
        }

    }

    Connections {
        function onRawEvent(event) {
            if (!isHyprland || event.name.endsWith("v2"))
                return ;

            if (event.name.includes("activelayout")) {
                refreshKeyboardLayout();
                getMonitors.running = true;
                getActiveWorkspace.running = true;
            } else if (event.name.includes("mon")) {
                Hyprland.refreshMonitors();
                getMonitors.running = true;
            } else if (event.name.includes("workspace")) {
                Hyprland.refreshWorkspaces();
                getWorkspaces.running = true;
                getActiveWorkspace.running = true;
            } else if (event.name.includes("window")) {
                Hyprland.refreshToplevels();
                getClients.running = true;
                getActiveWorkspace.running = true;
            }
            root.stateChanged();
        }

        target: isHyprland ? Hyprland : null
    }

}
