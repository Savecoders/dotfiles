// Config.qml — Central configuration singleton
// RULE: Outside of this file, do NOT write chained manual guards like `Config.settings && Config.settings.x && Config.settings.x.y`.
// Use `Config.get("x.y", fallback)` for safe path resolution with fallbacks, or `Config.settings` for reactive property bindings.

import QtCore
import QtQuick
import Quickshell
import Quickshell.Io
import qs.core
import qs.services
pragma Singleton

Singleton {
    id: root

    property string filePath: Directories.shellConfigPath
    property alias settings: jsonAdapterConfig
    property bool initialized: false
    property int readWriteDelay: 50
    property bool blockWrites: false
    property bool pauseAutoSave: false
    readonly property string barPosition: root.get("bar.position", "bottom").toLowerCase()

    function get(path, fallback) {
        let obj = root.settings;
        if (!obj || typeof path !== "string")
            return fallback;

        let keys = path.split(".");
        for (let i = 0; i < keys.length; ++i) {
            let k = keys[i];
            if (obj === null || obj === undefined || typeof obj !== "object" || obj[k] === undefined)
                return fallback;

            obj = obj[k];
        }
        return (obj !== undefined && obj !== null) ? obj : fallback;
    }

    function updateKey(nestedKey, value) {
        let keys = nestedKey.split(".");
        let obj = root.settings;
        if (!obj)
            return ;

        for (let i = 0; i < keys.length - 1; ++i) {
            let k = keys[i];
            if (obj[k] === undefined || obj[k] === null || typeof obj[k] !== "object")
                obj[k] = {
            };

            obj = obj[k];
            if (!obj)
                return ;

        }
        let convertedValue = value;
        if (typeof value === "string") {
            let trimmed = value.trim();
            if (trimmed === "true" || trimmed === "false" || (!isNaN(Number(trimmed)) && trimmed !== "")) {
                try {
                    convertedValue = JSON.parse(trimmed);
                } catch (e) {
                    convertedValue = value;
                }
            }
        }
        obj[keys[keys.length - 1]] = convertedValue;
        configFileView.adapterUpdated();
    }

    onPauseAutoSaveChanged: {
        root.blockWrites = root.pauseAutoSave;
        if (!root.pauseAutoSave)
            configFileView.adapterUpdated();

    }

    Timer {
        id: fileReloadTimer

        interval: root.readWriteDelay
        repeat: false
        onTriggered: configFileView.reload()
    }

    Timer {
        id: fileWriteTimer

        interval: root.readWriteDelay
        repeat: false
        onTriggered: configFileView.writeAdapter()
    }

    FileView {
        id: configFileView

        path: root.filePath
        watchChanges: true
        blockWrites: root.blockWrites
        onFileChanged: fileReloadTimer.restart()
        onAdapterUpdated: fileWriteTimer.restart()
        onLoaded: {
            root.initialized = true;
        }
        onLoadFailed: (error) => {
            if (error == FileViewError.FileNotFound)
                writeAdapter();

        }

        JsonAdapter {
            id: jsonAdapterConfig

            property var plugins: ({
            })
            property var monitors: ({
            })
            property int minutesBetweenHealthNotif: 30
            property string font: "SF Pro Display"
            property string iconFont: "Material Symbols Rounded"
            property int borderRadius: 20
            property int animationSpeed: 200
            property bool usePfpInsteadOfLogo: false
            property string pfpLocation: "~/.face"
            property string nightmodeColourTemp: "5500"
            property bool nightmodeOnStartup: false
            property string weatherLocation: "Guayaquil"
            property JsonObject bar
            property JsonObject desktop
            property string currentWallpaper: Quickshell.shellDir + "/assets/default_blank.png"
            property string previousWallpaper: "null"
            property string secondPreviousWallpaper: "null"
            property string wallpaperToSet: Quickshell.shellDir + "/assets/default_blank.png"
            property JsonObject colours
            property JsonObject componentControl
            property JsonObject recorder
            property JsonObject notifications
            property JsonObject overlays
            property JsonObject idle
            property JsonObject lockscreen
            property JsonObject misc
            property JsonObject shell

            onWeatherLocationChanged: {
                Weather.reload();
            }

            bar: JsonObject {
                property bool floating: true
                property bool smoothEdgesShown: false
                property bool workspacesCenterAligned: true
                property bool expand: false
                property string position: "left"
                property real opacity: 0.95
                property int margin: 10
                property var leftWidgets: ["icon", "workspaces"]
                property var rightWidgets: ["systray", "cpu", "ram", "temp", "battery", "notifications", "quickactions", "recording"]
            }

            desktop: JsonObject {
                property bool desktopRoundingShown: true
                property bool dimDesktopWallpaper: false
                property string targetScreen: "all"
                property int desktopGap: 4
                property int gapsIn: 4
                property int gapsOut: 16
                property int workspaceGaps: 0
            }

            colours: JsonObject {
                property bool enableScheme: true
                property string genType: "scheme-expressive"
                property string mode: "dark"
                property bool useCustom: false

                onEnableSchemeChanged: {
                    Wallpaper.changeColourProp();
                }
                onGenTypeChanged: {
                    Wallpaper.changeColourProp();
                }
                onModeChanged: {
                    Wallpaper.changeColourProp();
                }
                onUseCustomChanged: {
                    if (useCustom == false)
                        Wallpaper.changeColourProp();

                }
            }

            componentControl: JsonObject {
                property bool barIsEnabled: true
                property bool notifsIsEnabled: true
                property bool dashboardIsEnabled: true
                property bool lockscreenIsEnabled: true
                property bool desktopIsEnabled: true
            }

            recorder: JsonObject {
                property string screen: "eDP-1"
                property string encoder: "libx264"
                property string output_loc: "~/Videos"
                property int fps: 60
                property bool recordSystemAudio: true
                property bool recordMicrophone: false
            }

            notifications: JsonObject {
                property bool enabled: true
                property bool doNotDisturb: false
                property int timeout: 6000
                property string position: "top-right"
                property bool compactMode: false
                property bool showTimeoutBar: true
                property bool privacyMode: false
                property int maxVisiblePopups: 5
                property bool soundEnabled: true
            }

            overlays: JsonObject {
                property bool enabled: true
            }

            idle: JsonObject {
                property bool enabled: true
                property bool keepAwake: false
                property bool lockBeforeSuspend: true
                property bool fadeDimEnabled: true
                property JsonObject ac: JsonObject {
                    property int dimTimeout: 120
                    property int lockTimeout: 300
                    property int dpmsTimeout: 360
                    property int suspendTimeout: 1800
                }
                property JsonObject battery: JsonObject {
                    property int dimTimeout: 60
                    property int lockTimeout: 180
                    property int dpmsTimeout: 240
                    property int suspendTimeout: 600
                }
            }

            lockscreen: JsonObject {
                property bool blurBackground: true
                property bool showClock: true
                property bool showDate: true
                property bool showMedia: true
                property bool showSystemPill: true
                property bool showPowerBtn: true
            }

            misc: JsonObject {
                property string githubUsername: ""
                property int audioIncrement: 5
            }

            shell: JsonObject {
                property string version: "1.0.0"
            }

        }

    }

}
