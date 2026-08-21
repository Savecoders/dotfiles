import QtMultimedia
import QtQuick
import Quickshell
import Quickshell.Io
import qs.core
pragma Singleton

Singleton {
    id: root

    property bool isRecordingRunning: false
    property bool isPaused: false
    property int fps: 60
    property bool recordSystemAudio: true
    property bool recordMicrophone: false
    property string outputFile: ""
    property string fullOutputFile: ""
    property int seconds: 0
    property int minutes: 0
    property int hours: 0
    property string fullTime: "00:00:00"
    property int recorderExitCode: 0
    property bool readyToNotif: false
    property string _tempPickedPath: ""

    function getNormalizedDir() {
        let loc = (Config.settings && Config.settings.recorder && Config.settings.recorder.output_loc) ? Config.settings.recorder.output_loc : "~/Videos";
        let path = loc.startsWith("/") ? loc : `${Quickshell.env("HOME")}/${loc.replace(/^~\//, "")}`;
        return path.replace(/\/+$/, "");
    }

    function resetTime() {
        seconds = 0;
        minutes = 0;
        hours = 0;
        fullTime = "00:00:00";
        isPaused = false;
    }

    function closeRecording() {
        Quickshell.execDetached(["pkill", "-SIGINT", "wf-recorder"]);
    }

    function pauseRecording() {
        if (isRecordingRunning && !isPaused) {
            isPaused = true;
            Quickshell.execDetached(["pkill", "-SIGSTOP", "wf-recorder"]);
        }
    }

    function resumeRecording() {
        if (isRecordingRunning && isPaused) {
            isPaused = false;
            Quickshell.execDetached(["pkill", "-SIGCONT", "wf-recorder"]);
        }
    }

    function openRecordingsFolder() {
        Quickshell.execDetached(["thunar", root.getNormalizedDir()]);
    }

    function startRecording() {
        resetTime();
        let dir = root.getNormalizedDir();
        Quickshell.execDetached(["mkdir", "-p", dir]);
        let now = new Date();
        let pad = (n) => {
            return (n < 10 ? "0" + n : String(n));
        };
        let dateStr = `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())}-${pad(now.getHours())}-${pad(now.getMinutes())}-${pad(now.getSeconds())}`;
        root.outputFile = `capture_${dateStr}.mp4`;
        root.fullOutputFile = `${dir}/${root.outputFile}`;
        let screenName = (Config.settings && Config.settings.recorder && Config.settings.recorder.screen) ? Config.settings.recorder.screen : "eDP-1";
        let encoderName = (Config.settings && Config.settings.recorder && Config.settings.recorder.encoder) ? Config.settings.recorder.encoder : "libx264";
        let cmd = ["wf-recorder", "-o", screenName, "-c", encoderName, "-r", String(root.fps)];
        if (root.recordSystemAudio || root.recordMicrophone)
            cmd.push("-a");

        cmd.push("-f", root.fullOutputFile);
        recorderProc.command = cmd;
        recorderProc.running = false;
        recorderProc.running = true;
        root.isRecordingRunning = true;
    }

    function stopRecording() {
        let savedPath = fullOutputFile;
        resetTime();
        root.isRecordingRunning = false;
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
        zenityPicker.running = false;
        zenityPicker.running = true;
    }

    onRecorderExitCodeChanged: {
        if (recorderExitCode != 0 && recorderExitCode != 130 && recorderExitCode != 2) {
            let scr = (Config.settings && Config.settings.recorder && Config.settings.recorder.screen) ? Config.settings.recorder.screen : "eDP-1";
            Quickshell.execDetached(["notify-send", "Failed to start recording", `Check output folder or screen: ${scr}`]);
            recorderExitCode = 0;
        }
    }

    Timer {
        interval: 1000
        running: isRecordingRunning && !isPaused
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
