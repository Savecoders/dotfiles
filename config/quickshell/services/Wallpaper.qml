import QtQuick
import Quickshell
import Quickshell.Io
import qs.core
pragma Singleton

Singleton {
    id: root

    property var wallpapersList: []
    property string homeDir: Quickshell.env("HOME") || ""
    property var _tempBuffer: []

    function cleanWallpaperPath(path) {
        let str = `${path}`;
        if (str.startsWith("file://"))
            str = str.substring(7);

        if (str.startsWith("~/"))
            str = root.homeDir + str.substring(1);

        return str;
    }

    function getMatugenArgs(cleanPath) {
        let mode = Config.get("colours.mode", "dark");
        let enableScheme = Config.get("colours.enableScheme", true);
        let genType = Config.get("colours.genType", "scheme-expressive");
        let sourceIndex = Config.get("colours.sourceColorIndex", 0);
        let args = ["matugen", "image", cleanPath, "-m", `${mode}`, "--source-color-index", `${sourceIndex}`];
        if (enableScheme !== false) {
            args.push("-t");
            args.push(`${genType}`);
        }
        return args;
    }

    function setNewWallpaper(path) {
        let clean = cleanWallpaperPath(path);
        let secondPrev = `${Config.get("previousWallpaper", "null")}`;
        let prev = `${Config.get("currentWallpaper", "")}`;

        // Update Config settings
        Config.pauseAutoSave = true;
        Config.updateKey("secondPreviousWallpaper", secondPrev);
        Config.updateKey("previousWallpaper", prev);
        Config.updateKey("currentWallpaper", clean);
        Config.updateKey("wallpaperToSet", clean);
        Config.pauseAutoSave = false;

        // Update ~/.current.wall symlink
        Quickshell.execDetached(["sh", "-c", "ln -sf \"" + clean + "\" ~/.current.wall"]);

        // Apply wallpaper with awww/swww daemon using dynamic transitions
        let transitions = ["grow", "outer", "wave", "circle", "wipe", "center", "fade"];
        let trans = transitions[Math.floor(Math.random() * transitions.length)];
        Quickshell.execDetached(["sh", "-c", "if command -v awww >/dev/null 2>&1; then awww img \"" + clean + "\" --transition-type " + trans + " --transition-duration 1.2 --transition-fps 60; elif command -v swww >/dev/null 2>&1; then swww img \"" + clean + "\" --transition-type " + trans + " --transition-duration 1.2 --transition-fps 60; fi"]);

        // Run Matugen to regenerate themes unless custom colours are enabled
        if (!Config.get("colours.useCustom", false))
            Quickshell.execDetached(getMatugenArgs(clean));

        Quickshell.execDetached(["notify-send", "Wallpaper & Theme Updated", "New wallpaper and color palette applied."]);
    }

    function changeColourProp() {
        if (Config.get("colours.useCustom", false))
            return ;

        let clean = cleanWallpaperPath(Config.get("currentWallpaper", ""));
        if (clean && clean !== "")
            Quickshell.execDetached(getMatugenArgs(clean));

    }

    function setRandomWallpaper() {
        if (!wallpapersList || wallpapersList.length === 0)
            return ;

        let randomIndex = Math.floor(Math.random() * wallpapersList.length);
        setNewWallpaper(wallpapersList[randomIndex]);
    }

    function reloadWallpapers() {
        root._tempBuffer = [];
        scanProc.running = false;
        Qt.callLater(() => {
            scanProc.running = true;
        });
    }

    Component.onCompleted: {
        reloadWallpapers();
    }

    Process {
        id: scanProc

        command: ["sh", "-c", "find -L '" + root.homeDir + "/Pictures/Wallpapers' -type f \\( -name '*.jpg' -o -name '*.png' -o -name '*.jpeg' -o -name '*.webp' -o -name '*.JPG' -o -name '*.PNG' \\) | sort"]
        running: true
        onExited: {
            Qt.callLater(() => {
                if (root._tempBuffer.length > 0)
                    root.wallpapersList = root._tempBuffer.slice();

            });
        }

        stdout: SplitParser {
            onRead: (data) => {
                let line = `${data}`.trim();
                if (line.length > 0 && root._tempBuffer.indexOf(line) === -1)
                    root._tempBuffer.push(line);

            }
        }

    }

}
