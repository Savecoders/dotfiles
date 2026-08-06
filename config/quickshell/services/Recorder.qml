import QtMultimedia
import QtQuick
import Quickshell
import Quickshell.Io
import qs.core
pragma Singleton

Singleton {
    id: root

    property bool isRecordingRunning: false
    property string outputFile: "capture_undefined.mp4"
    property string fullOutputFile: `${root.getNormalizedDir()}/${root.outputFile}`
    property int seconds: 0
    property int minutes: 0
    property int hours: 0
    property string fullTime: "00:00:00"
    property int recorderExitCode: 0
    property bool readyToNotif: false
    property bool _pendingStart: false
    property string _tempPickedPath: ""

    function getNormalizedDir() {
        let loc = Config.settings.recorder.output_loc || "~/Videos";
        let path = loc.startsWith("/") ? loc : `${Quickshell.env("HOME")}/${loc.replace(/^~\//, "")}`;
        return path.replace(/\/+$/, "");
    }

    function resetTime() {
        seconds = 0;
        minutes = 0;
        hours = 0;
        fullTime = "00:00:00";
    }

    function closeRecording() {
        Quickshell.execDetached(["pkill", "-SIGINT", "wf-recorder"]);
    }

    function startRecording() {
        resetTime();
        let dir = root.getNormalizedDir();
        Quickshell.execDetached(["mkdir", "-p", dir]);
        isRecordingRunning = true;
        _pendingStart = true;
        dateProc.running = true;
    }

    function stopRecording() {
        let savedPath = fullOutputFile;
        resetTime();
        isRecordingRunning = false;
        dateProc.running = false;
        closeRecording();
        Qt.callLater(() => {
            Quickshell.execDetached(["notify-send", "Screen Recording Saved", savedPath]);
        });
    }

    function toggleRecording() {
        if (isRecordingRunning)
            stopRecording();
        else
            startRecording();
    }

    function openFolderPicker() {
        let dir = root.getNormalizedDir() + "/";
        zenityPicker.command = ["bash", "-c", `zenity --file-selection --directory --filename='${dir}' --title='Select Video Output Directory' 2>/dev/null`];
        zenityPicker.running = true;
    }

    onRecorderExitCodeChanged: {
        if (recorderExitCode != 0 && recorderExitCode != 130 && recorderExitCode != 2) {
            Quickshell.execDetached(["notify-send", "Failed to start recording", `Check output folder or screen: ${Config.settings.recorder.screen}`]);
            recorderExitCode = 0;
        }
    }
    onOutputFileChanged: {
        let cleanName = root.outputFile.trim();
        fullOutputFile = `${root.getNormalizedDir()}/${cleanName}`;
        if (_pendingStart) {
            _pendingStart = false;
            let screenName = Config.settings.recorder.screen || "eDP-1";
            let encoderName = Config.settings.recorder.encoder || "libx264";
            recorderProc.command = ["wf-recorder", "-o", screenName, "-c", encoderName, "-f", fullOutputFile];
            recorderProc.running = true;
        }
    }

    Timer {
        interval: 1000
        running: isRecordingRunning
        repeat: true
        onTriggered: {
            seconds += 1;
            if (seconds == 60) {
                minutes += 1;
                seconds = 0;
            }
            if (minutes == 60) {
                hours += 1;
                minutes = 0;
            }
            let formattedSeconds = seconds < 10 ? `0${seconds}` : `${seconds}`;
            let formattedMinutes = minutes < 10 ? `0${minutes}` : `${minutes}`;
            let formattedHours = hours < 10 ? `0${hours}` : `${hours}`;
            fullTime = `${formattedHours}:${formattedMinutes}:${formattedSeconds}`;
        }
    }

    Process {
        id: recorderProc

        running: false
        onExited: (exitCode) => {
            recorderExitCode = exitCode;
            root.isRecordingRunning = false;
        }
    }

    Process {
        id: isRecordingRunningProc

        running: true
        command: ["pgrep", "wf-recorder"]
        onExited: (exitCode) => {
            root.isRecordingRunning = (exitCode === 0);
        }
    }

    Process {
        id: dateProc

        running: false
        command: ["date", "+%Y-%m-%d-%H-%M-%S"]

        stdout: SplitParser {
            onRead: (data) => {
                let clean = `${data}`.trim();
                if (clean.length > 0)
                    root.outputFile = `capture_${clean}.mp4`;

            }
        }

    }

    Process {
        id: zenityPicker

        running: false
        onExited: (exitCode) => {
            if (exitCode === 0 && root._tempPickedPath.length > 0) {
                let path = root._tempPickedPath;
                Config.updateKey("recorder.output_loc", path);
            }
            root._tempPickedPath = "";
            reopenTimer.restart();
        }

        stdout: SplitParser {
            onRead: (data) => {
                let p = `${data}`.trim();
                if (p.length > 0)
                    root._tempPickedPath = p;

            }
        }

    }

    Timer {
        id: reopenTimer

        interval: 150
        repeat: false
        onTriggered: {
            if (!IPCLoader.isSettingsOpen)
                IPCLoader.toggleSettings();

        }
    }

}
