import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
pragma Singleton

Singleton {
    id: root

    property string detectedCompositor: ""
    readonly property var backend: {
        if (detectedCompositor === "hyprland")
            return Hyprland;

        return null;
    }
    property string title: (backend && backend.title) ? backend.title : ""
    property bool isFullscreen: (backend && backend.isFullscreen) ? backend.isFullscreen : false
    property string layout: (backend && backend.layout) ? backend.layout : "Tiled"
    property int focusedWorkspaceId: (backend && backend.focusedWorkspaceId) ? backend.focusedWorkspaceId : 1
    property var workspaces: (backend && backend.workspaces) ? backend.workspaces : []
    property var windowList: (backend && backend.windowList) ? backend.windowList : []
    property bool initialized: (backend && backend.initialized !== undefined) ? backend.initialized : true
    property int workspaceCount: (backend && backend.workspaceCount) ? backend.workspaceCount : 0
    property real screenW: (backend && backend.screenW) ? backend.screenW : 0
    property real screenH: (backend && backend.screenH) ? backend.screenH : 0
    property real screenScale: (backend && backend.screenScale) ? backend.screenScale : 1
    readonly property Toplevel activeToplevel: ToplevelManager.activeToplevel

    signal stateChanged()

    function require(compositors) {
        if (Array.isArray(compositors))
            return compositors.includes(detectedCompositor);

        return compositors === detectedCompositor;
    }

    function changeWorkspace(id) {
        if (backend && backend.changeWorkspace)
            backend.changeWorkspace(id);

    }

    function changeWorkspaceRelative(delta) {
        if (backend && backend.changeWorkspaceRelative)
            backend.changeWorkspaceRelative(delta);

    }

    function isWorkspaceOccupied(id) {
        return (backend && backend.isWorkspaceOccupied) ? backend.isWorkspaceOccupied(id) : false;
    }

    function focusedWindowForWorkspace(id) {
        return (backend && backend.focusedWindowForWorkspace) ? backend.focusedWindowForWorkspace(id) : null;
    }

    Process {
        command: ["sh", "-c", "echo \"$XDG_CURRENT_DESKTOP $XDG_SESSION_DESKTOP\""]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                const val = data.trim().toLowerCase();
                if (val.includes("hyprland"))
                    root.detectedCompositor = "hyprland";

            }
        }

    }

    Connections {
        function onStateChanged() {
            root.stateChanged();
        }

        target: backend
    }

}
