import QtQuick
import Quickshell
import qs.services
pragma Singleton

Singleton {
    id: root

    readonly property var hyprWorkspaces: {
        if (!Hyprland.isHyprland || !Hyprland.workspaces || !Hyprland.workspaces.values)
            return [];

        let list = Hyprland.workspaces.values.map((ws) => {
            return {
                "id": ws.id,
                "windows": ws.lastIpcObject ? (ws.lastIpcObject.windows || 0) : 0
            };
        });
        list.sort((a, b) => {
            return a.id - b.id;
        });
        return list;
    }
    readonly property var activeWorkspace: Hyprland.focusedWorkspace
}
