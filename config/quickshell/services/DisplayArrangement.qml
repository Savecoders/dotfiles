pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

Singleton {
    id: root

    readonly property var monitorsInfo: Hyprland.monitorsInfo
    readonly property bool available: Hyprland.isHyprland
    property bool busy: false
    readonly property bool confirmationBusy: _pendingAction !== null || (busy && _action !== "status")
    property var _pendingAction: null
    property string phase: "idle"
    property string error: ""
    property string token: ""
    property double deadline: 0
    property var snapshotData: null
    property string _action: ""
    property string _stdout: ""
    property string _stderr: ""
    property bool _stdoutDone: false
    property bool _stderrDone: false
    property bool _exited: false
    property int _exitCode: 0
    property int _exitStatus: 0

    signal finished(string action, var result)
    signal failed(string action, string message)

    function refresh() {
        return send("snapshot", {});
    }

    function apply(snapshot, positions) {
        return send("apply", { snapshot: snapshot, positions: positions });
    }

    function confirm() {
        return send("confirm", { token: root.token });
    }

    function revert() {
        return send("revert", { token: root.token });
    }

    function send(action, data) {
        if (!available || _pendingAction !== null)
            return false;
        if (busy) {
            if (_action !== "status" || phase !== "confirming" || token === ""
                || (action !== "confirm" && action !== "revert") || data.token !== token
                || (action === "confirm" && deadline <= Date.now()))
                return false;
            _pendingAction = {action: action, data: {token: data.token}};
            return true;
        }
        requestRunner.start(action, data);
        return true;
    }

    function validResult(action, result) {
        if (!result || typeof result !== "object" || Array.isArray(result))
            return false;
        if (action === "snapshot") {
            const proof = result.proof;
            return Array.isArray(result.monitors) && proof && typeof proof.generation === "string"
                && proof.positions && typeof proof.positions === "object" && !Array.isArray(proof.positions)
                && result.monitors.every(monitor => monitor && typeof monitor.name === "string"
                    && typeof proof.positions[monitor.name] === "string"
                    && ["x", "y", "width", "height", "scale", "transform"].every(key =>
                        typeof monitor[key] === "number" && isFinite(monitor[key])));
        }
        return ["idle", "confirming", "recovery"].indexOf(result.phase) !== -1
            && typeof result.token === "string" && typeof result.deadline === "number" && isFinite(result.deadline)
            && typeof result.error === "string";
    }

    function completeIfReady() {
        if (!_exited || !_stdoutDone || !_stderrDone)
            return;
        // Leave the Process completion stack before a signal handler can start it again.
        Qt.callLater(root.complete);
    }

    function complete() {
        const action = _action;
        const pending = _pendingAction;
        const stdout = _stdout;
        const stderr = _stderr;
        const unsuccessful = _exitCode !== 0 || _exitStatus !== 0;
        let result = null;
        let message = "";
        if (unsuccessful) {
            message = stderr.trim() || "The display controller could not complete the request.";
        } else {
            try {
                result = JSON.parse(stdout);
                if (!validResult(action, result))
                    throw new Error("Invalid controller result");
            } catch (exception) {
                message = "The display controller returned an invalid response.";
            }
        }
        if (message) {
            root.error = message;
        } else {
            if (action === "snapshot")
                root.snapshotData = result;
            if (result.phase !== undefined) {
                root.phase = result.phase;
                root.token = result.token;
                root.deadline = result.deadline;
                root.error = result.error;
            }
        }
        if (!message || unsuccessful)
            Hyprland.updateAll();
        // busyChanged and finished/failed may synchronously request another operation.
        // Publish all state first, and only use local values after releasing busy.
        root.busy = false;
        if (message)
            root.failed(action, message);
        else
            root.finished(action, result);
        if (pending !== null) {
            if (!message && root.available && root.phase === "confirming" && root.error === ""
                && root.token === pending.data.token
                && (pending.action !== "confirm" || root.deadline > Date.now())) {
                requestRunner.start(pending.action, pending.data);
            } else {
                root.failed(pending.action, root.error || "Display confirmation changed. Review the current state before trying again.");
            }
            root._pendingAction = null;
        }
    }

    QtObject {
        id: requestRunner

        function start(action, data) {
            root._action = action;
            root.busy = true;
            root.error = "";
            root._stdout = "";
            root._stderr = "";
            root._stdoutDone = false;
            root._stderrDone = false;
            root._exited = false;
            helper.command = ["node", Quickshell.shellDir + "/scripts/display-arrangement.js", action, JSON.stringify(data)];
            helper.running = true;
        }
    }

    function initialize() {
        if (available && !busy)
            send("status", {});
    }

    onAvailableChanged: {
        if (available)
            Qt.callLater(root.initialize);
    }

    Component.onCompleted: initialize()

    Timer {
        interval: 500
        repeat: true
        running: root.available && (root.phase === "confirming" || root.phase === "recovery")
        onTriggered: root.send("status", {})
    }

    Process {
        id: helper
        stdout: StdioCollector {
            onStreamFinished: {
                root._stdout = text;
                root._stdoutDone = true;
                root.completeIfReady();
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                root._stderr = text;
                root._stderrDone = true;
                root.completeIfReady();
            }
        }
        onExited: (exitCode, exitStatus) => {
            root._exitCode = exitCode;
            root._exitStatus = exitStatus;
            root._exited = true;
            root.completeIfReady();
        }
    }
}
