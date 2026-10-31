import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.core
import qs.services
import qs.features
import qs.features.settings.content.generics
import "../../../lib/DisplayArrangementGeometry.js" as Geometry

ColumnLayout {
    id: root
    objectName: "displayArrangementEditor"
    spacing: Styling.spacing.md

    property var monitorsInfo: Hyprland.monitorsInfo
    property var controller: DisplayArrangement
    readonly property var live: Geometry.monitors(monitorsInfo)
    property var draft: []
    property var monitorNames: []
    property string lastObservation: ""
    property var snapshotBaseline: null
    property string selectedName: ""
    property string activeMonitor
    property string localError: ""
    property bool refreshPending: false
    property var dragBounds: null
    property int draftGeneration: 0
    property double now: Date.now()
    readonly property var selected: draft.find(m => m.name === selectedName) || null
    readonly property string invalid: Geometry.validation(draft)
    readonly property bool editing: !controller.busy && controller.phase === "idle"
    readonly property bool changed: !Geometry.matches(draft, live)
    readonly property bool supported: live.length === (monitorsInfo || []).length
        && !(monitorsInfo || []).some(m => m.disabled || (m.mirrorOf && m.mirrorOf !== "none"))
    readonly property bool canApply: editing && snapshotBaseline !== null && supported && changed
        && live.length > 0 && invalid === "" && localError === "" && controller.error === ""
        && coordinateX.acceptableInput && coordinateY.acceptableInput
    readonly property var viewBounds: dragBounds || Geometry.bounds(draft)
    readonly property real baseCanvasHeight: Styling.fontSize.md * 16
    readonly property real factor: Math.max(0.001, Math.min(
        (width - canvas.inset * 2) / Math.max(1, Geometry.bounds(live).width),
        (baseCanvasHeight - canvas.inset * 2) / Math.max(1, Geometry.bounds(live).height)))
    readonly property int remaining: Math.max(0, Math.ceil((controller.deadline - now) / 1000))
    readonly property string status: {
        if (controller.error) return controller.error + " Use Refresh after resolving the controller or Hyprland bridge error.";
        if (controller.phase === "confirming") return "Review the applied arrangement, then Keep or Revert. Unconfirmed changes revert automatically.";
        if (controller.phase === "recovery") return "Display recovery is required. Reload Hyprland, then Refresh.";
        if (!live.length) return "No connected displays reported by Hyprland.";
        if (!supported) return "Unsupported display geometry or mirroring. Disable mirroring, then Refresh.";
        if (localError) return localError;
        if (controller.busy) return "Waiting for the display controller…";
        if (invalid) return invalid;
        if (!snapshotBaseline) return "Apply unavailable. Refresh to verify the Hyprland bridge and monitor rules.";
        return changed ? "Draft only. Apply to preview this arrangement." : "Drag a display or enter logical X/Y coordinates. Changes stay in the draft until Apply.";
    }

    function resetDraft() {
        draftGeneration++;
        draft = live.map(m => Object.assign({}, m));
        const names = live.map(m => m.name);
        if (JSON.stringify(names) !== JSON.stringify(monitorNames))
            monitorNames = names;
        if (!draft.some(m => m.name === selectedName))
            selectedName = draft.length ? draft[0].name : "";
        dragBounds = null;
    }

    function refresh() {
        snapshotBaseline = null;
        localError = "";
        refreshPending = true;
        requestRefresh();
    }

    function requestRefresh() {
        if (!refreshPending || controller.busy || controller.phase !== "idle") return;
        refreshPending = false;
        if (!controller.refresh())
            localError = "Display controller unavailable. Enable the Hyprland bridge and reload Hyprland, then Refresh.";
    }

    function move(name, x, y, project) {
        if (!editing) return;
        localError = "";
        if (project) {
            const target = Geometry.snapped(draft, name, x, y, Styling.spacing.md / factor);
            const candidate = draft.map(m => m.name === name ? Object.assign({}, m, {x: target.x, y: target.y}) : m);
            if (Geometry.validation(candidate) === "") {
                draft = candidate;
                return;
            }
            const placed = Geometry.placement(draft, name, x, y, Styling.spacing.md / factor);
            draft = draft.map(m => m.name === name ? Object.assign({}, m, {x: placed.x, y: placed.y}) : m);
            return;
        }
        const candidate = draft.map(m => m.name === name ? Object.assign({}, m, {x: x, y: y}) : m);
        const error = Geometry.validation(candidate);
        if (error) {
            localError = error + " The last valid position was kept.";
            return;
        }
        draft = candidate;
    }

    function drop(name, startX, startY, targetX, targetY) {
        if (!editing) return;
        const moving = draft.find(m => m.name === name);
        if (!moving) return;
        const centerX = targetX + moving.logicalWidth / 2;
        const centerY = targetY + moving.logicalHeight / 2;
        const other = draft.find(m => m.name !== name
            && centerX >= m.x && centerX < m.x + m.logicalWidth
            && centerY >= m.y && centerY < m.y + m.logicalHeight);
        if (!other) return;
        const candidate = draft.map(m => m.name === name
            ? Object.assign({}, m, {x: other.x, y: other.y})
            : m.name === other.name ? Object.assign({}, m, {x: startX, y: startY}) : m);
        if (Geometry.validation(candidate) === "")
            draft = candidate;
    }

    function coordinate(axis, text) {
        if (!selected || !editing) return;
        if (!/^-?\d+$/.test(text) || Math.abs(Number(text)) > 100000) {
            localError = "Enter integer coordinates between -100000 and 100000.";
            return;
        }
        move(selectedName, axis === "x" ? Number(text) : selected.x, axis === "y" ? Number(text) : selected.y, false);
        coordinateX.text = Qt.binding(() => root.selected ? String(root.selected.x) : "");
        coordinateY.text = Qt.binding(() => root.selected ? String(root.selected.y) : "");
    }

    onActiveMonitorChanged: {
        if (activeMonitor !== "" && activeMonitor !== "all" && draft.some(m => m.name === activeMonitor))
            selectedName = activeMonitor;
    }
    onLiveChanged: {
        const observation = Geometry.observation(monitorsInfo);
        if (observation === lastObservation) return;
        lastObservation = observation;
        snapshotBaseline = null;
        localError = "Displays changed. The draft was reset; Refresh before applying.";
        resetDraft();
    }
    Component.onCompleted: { resetDraft(); refresh(); }

    Connections {
        target: root.controller
        function onBusyChanged() { root.requestRefresh(); }
        function onFinished(action, result) {
            if (action === "snapshot") {
                if (result && result.proof && Geometry.matches(root.live, Geometry.monitors(result.monitors))) {
                    root.snapshotBaseline = result;
                    root.localError = "";
                } else {
                    root.snapshotBaseline = null;
                    root.localError = "Display snapshot changed or is unsupported. Refresh before applying.";
                }
            } else if (action === "apply") {
                root.snapshotBaseline = null;
            } else if (action === "confirm" || action === "revert") {
                root.refresh();
            } else if (action === "status" && root.controller.phase === "idle" && !root.snapshotBaseline) {
                root.requestRefresh();
            }
        }
        function onFailed(action, message) {
            root.snapshotBaseline = null;
            root.localError = message;
        }
    }

    Timer {
        interval: 250
        running: root.controller.phase === "confirming"
        repeat: true
        triggeredOnStart: true
        onTriggered: root.now = Date.now()
    }

    Text {
        text: "Display Arrangement"
        font.family: Config.settings.font
        font.pixelSize: Styling.fontSize.title
        color: Colours.palette.on_surface
    }

    StyledRect {
        id: canvas
        objectName: "arrangementCanvas"
        variant: "internalbg"
        Layout.fillWidth: true
        Layout.preferredHeight: Math.max(root.baseCanvasHeight, root.viewBounds.height * root.factor + inset * 2)
        clip: true
        readonly property real inset: Styling.spacing.lg
        readonly property real originX: (width - root.viewBounds.width * root.factor) / 2
        readonly property real originY: (height - root.viewBounds.height * root.factor) / 2

        Repeater {
            model: root.monitorNames
            delegate: MonitorCard {
                id: monitor
                required property var modelData
                readonly property var geometry: root.draft.find(m => m.name === modelData) || root.live.find(m => m.name === modelData)
                    || {x: 0, y: 0, logicalWidth: 0, logicalHeight: 0}
                objectName: "arrangementMonitor_" + modelData
                label: modelData
                resolution: geometry.logicalWidth + " × " + geometry.logicalHeight
                details: geometry.x + ", " + geometry.y
                selected: root.selectedName === modelData
                invalid: root.invalid !== ""
                hovered: pointer.containsMouse
                x: canvas.originX + (geometry.x - root.viewBounds.x) * root.factor
                y: canvas.originY + (geometry.y - root.viewBounds.y) * root.factor
                width: geometry.logicalWidth * root.factor
                height: geometry.logicalHeight * root.factor

                MouseArea {
                    id: pointer
                    anchors.fill: parent
                    preventStealing: true
                    cursorShape: root.editing ? Qt.SizeAllCursor : Qt.PointingHandCursor
                    property point start
                    property point dragStartPosition
                    property point lastTarget
                    property int pressGeneration: -1
                    onPressed: mouse => {
                        pressGeneration = root.draftGeneration;
                        root.selectedName = monitor.modelData;
                        start = mapToItem(canvas, mouse.x, mouse.y);
                        dragStartPosition = Qt.point(monitor.geometry.x, monitor.geometry.y);
                        lastTarget = Qt.point(dragStartPosition.x, dragStartPosition.y);
                        root.dragBounds = root.viewBounds;
                    }
                    onPositionChanged: mouse => {
                        if (!pressed || !root.editing || pressGeneration !== root.draftGeneration) return;
                        const point = mapToItem(canvas, mouse.x, mouse.y);
                        const rawX = dragStartPosition.x + (point.x - start.x) / root.factor;
                        const rawY = dragStartPosition.y + (point.y - start.y) / root.factor;
                        lastTarget = Qt.point(rawX, rawY);
                        root.move(monitor.modelData, rawX, rawY, true);
                    }
                    onReleased: {
                        if (pressGeneration === root.draftGeneration) {
                            root.dragBounds = null;
                            root.drop(monitor.modelData, dragStartPosition.x, dragStartPosition.y, lastTarget.x, lastTarget.y);
                        }
                        pressGeneration = -1;
                    }
                    onCanceled: {
                        if (pressGeneration === root.draftGeneration)
                            root.dragBounds = null;
                        pressGeneration = -1;
                    }
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Styling.spacing.sm
        Text {
            text: root.selectedName || "No display selected"
            Layout.fillWidth: true
            elide: Text.ElideRight
            font.family: Config.settings.font
            font.pixelSize: Styling.fontSize.body
            color: Colours.palette.on_surface
        }
        Text {
            text: "X"
            color: Colours.palette.on_surface
            font.family: Config.settings.font
        }
        CoordinateInput {
            id: coordinateX
            objectName: "arrangementX"
            text: root.selected ? String(root.selected.x) : ""
            onEditingFinished: root.coordinate("x", text)
        }
        Text {
            text: "Y"
            color: Colours.palette.on_surface
            font.family: Config.settings.font
        }
        CoordinateInput {
            id: coordinateY
            objectName: "arrangementY"
            text: root.selected ? String(root.selected.y) : ""
            onEditingFinished: root.coordinate("y", text)
        }
    }

    Text {
        objectName: "arrangementStatus"
        Layout.fillWidth: true
        text: root.status
        wrapMode: Text.WordWrap
        font.family: Config.settings.font
        font.pixelSize: Styling.fontSize.body
        color: root.controller.error || root.localError || root.invalid ? Colours.palette.error : Colours.palette.on_surface_variant
        Accessible.role: Accessible.StaticText
        Accessible.name: text
    }
    Text {
        objectName: "arrangementCountdown"
        visible: root.controller.phase === "confirming"
        text: "Reverting in " + root.remaining + " seconds"
        color: Colours.palette.primary
        font.family: Config.settings.font
        font.pixelSize: Styling.fontSize.body
    }
    Flow {
        objectName: "arrangementActions"
        Layout.fillWidth: true
        spacing: Styling.spacing.sm
        ActionButton {
            objectName: "arrangementRefresh"
            text: "Refresh"
            enabled: root.editing
            onClicked: root.refresh()
        }
        ActionButton {
            text: "Reset Draft"
            enabled: root.editing
            onClicked: { root.localError = ""; root.resetDraft(); }
        }
        ActionButton {
            objectName: "arrangementApply"
            text: "Apply"
            enabled: root.canApply
            onClicked: {
                const positions = root.draft.filter(m => {
                    const before = root.live.find(n => n.name === m.name);
                    return before && (before.x !== m.x || before.y !== m.y);
                }).map(m => ({name: m.name, x: m.x, y: m.y}));
                if (!root.controller.apply(root.snapshotBaseline, positions))
                    root.localError = "Apply could not start. Refresh the controller state and try again.";
            }
        }
        ActionButton {
            objectName: "arrangementKeep"
            text: "Keep"
            visible: root.controller.phase === "confirming"
            enabled: !root.controller.busy && root.remaining > 0
            onClicked: root.controller.confirm()
        }
        ActionButton {
            objectName: "arrangementRevert"
            text: "Revert"
            visible: root.controller.phase === "confirming"
            enabled: !root.controller.busy
            onClicked: root.controller.revert()
        }
    }

    component CoordinateInput: TextField {
        Layout.preferredWidth: Styling.fontSize.md * 6
        enabled: root.editing && root.selected !== null
        selectByMouse: true
        validator: IntValidator { bottom: -100000; top: 100000 }
        color: Colours.palette.on_surface
        font.family: Config.settings.font
        font.pixelSize: Styling.fontSize.body
        background: StyledRect { variant: "common" }
        Accessible.name: objectName === "arrangementX" ? "Logical X coordinate" : "Logical Y coordinate"
    }
    component ActionButton: AbstractButton {
        id: button
        implicitWidth: label.implicitWidth + Styling.spacing.lg * 2
        implicitHeight: label.implicitHeight + Styling.spacing.md * 2
        opacity: enabled ? 1 : 0.5
        background: StyledRect { variant: button.down ? "focus" : "common" }
        contentItem: Text {
            id: label
            text: button.text
            font.family: Config.settings.font
            font.pixelSize: Styling.fontSize.body
            color: Colours.palette.on_surface
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
