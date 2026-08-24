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
    property int fps: Config.get("recorder.fps", 60)
    property bool recordSystemAudio: Config.get("recorder.recordSystemAudio", true)
    property bool recordMicrophone: Config.get("recorder.recordMicrophone", false)
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
        let loc = Config.get("recorder.output_loc", "~/Videos");
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
        let screenName = Config.get("recorder.screen", "eDP-1");
        let encoderName = Config.get("recorder.encoder", "libx264");
        let fpsVal = root.fps || 60;
        let recSys = root.recordSystemAudio ? "1" : "0";
        let recMic = root.recordMicrophone ? "1" : "0";
        let bashScript = `
screenName='${screenName}'
encoderName='${encoderName}'
fps='${fpsVal}'
outputFile='${root.fullOutputFile}'
recSys='${recSys}'
recMic='${recMic}'

cleanup() {
    if [ -n "$MOD_SYS" ]; then pactl unload-module "$MOD_SYS" 2>/dev/null || true; fi
    if [ -n "$MOD_MIC" ]; then pactl unload-module "$MOD_MIC" 2>/dev/null || true; fi
    if [ -n "$MOD_SINK" ]; then pactl unload-module "$MOD_SINK" 2>/dev/null || true; fi
}
trap cleanup EXIT INT TERM

AUDIO_ARG=()
if [ "$recSys" = "1" ] && [ "$recMic" = "1" ]; then
    MIX_SINK="RecorderMix_$$"
    MOD_SINK=$(pactl load-module module-null-sink sink_name="$MIX_SINK" sink_properties=device.description=RecorderMix 2>/dev/null)
    MOD_MIC=$(pactl load-module module-loopback source="$(pactl get-default-source)" sink="$MIX_SINK" latency_msec=20 2>/dev/null)
    MOD_SYS=$(pactl load-module module-loopback source="$(pactl get-default-sink).monitor" sink="$MIX_SINK" latency_msec=20 2>/dev/null)
    AUDIO_ARG=("--audio=\${MIX_SINK}.monitor")
elif [ "$recSys" = "1" ]; then
    SYS_SINK="$(pactl get-default-sink).monitor"
    AUDIO_ARG=("--audio=\${SYS_SINK}")
elif [ "$recMic" = "1" ]; then
    MIC_SRC="$(pactl get-default-source)"
    AUDIO_ARG=("--audio=\${MIC_SRC}")
fi

wf-recorder -o "$screenName" -c "$encoderName" -r "$fps" "\${AUDIO_ARG[@]}" -f "$outputFile"
`;
        recorderProc.command = ["bash", "-c", bashScript];
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

    onFpsChanged: {
        if (Config.get("recorder.fps", 60) !== fps)
            Config.updateKey("recorder.fps", fps);

    }
    onRecordSystemAudioChanged: {
        if (Config.get("recorder.recordSystemAudio", true) !== recordSystemAudio)
            Config.updateKey("recorder.recordSystemAudio", recordSystemAudio);

    }
    onRecordMicrophoneChanged: {
        if (Config.get("recorder.recordMicrophone", false) !== recordMicrophone)
            Config.updateKey("recorder.recordMicrophone", recordMicrophone);

    }
    onRecorderExitCodeChanged: {
        if (recorderExitCode !== 0 && recorderExitCode !== 130 && recorderExitCode !== 2) {
            let scr = Config.get("recorder.screen", "eDP-1");
            Quickshell.execDetached(["notify-send", "Failed to start recording", `Check output folder or screen: ${scr}`]);
            recorderExitCode = 0;
        }
    }

    Connections {
        function onFpsChanged() {
            const val = Config.get("recorder.fps", root.fps);
            if (root.fps !== val)
                root.fps = val;

        }

        function onRecordSystemAudioChanged() {
            const val = Config.get("recorder.recordSystemAudio", root.recordSystemAudio);
            if (root.recordSystemAudio !== val)
                root.recordSystemAudio = val;

        }

        function onRecordMicrophoneChanged() {
            const val = Config.get("recorder.recordMicrophone", root.recordMicrophone);
            if (root.recordMicrophone !== val)
                root.recordMicrophone = val;

        }

        target: Config.settings.recorder
    }

    Timer {
        interval: 1000
        running: isRecordingRunning && !isPaused
        repeat: true
        onTriggered: {
            seconds += 1;
            if (seconds === 60) {
                minutes += 1;
                seconds = 0;
            }
            if (minutes === 60) {
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
