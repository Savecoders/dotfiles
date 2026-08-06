pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.core

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
        let args = ["matugen", "image", cleanPath, "-m", `${Config.settings.colours.mode}`, "--source-color-index", "0"];
        if (Config.settings.colours.enableScheme !== false) {
            args.push("-t");
            args.push(`${Config.settings.colours.genType}`);
        }
        return args;
    }

    function setNewWallpaper(path) {
        let clean = cleanWallpaperPath(path);
        let secondPrev = `${Config.settings.previousWallpaper}`;
        let prev = `${Config.settings.currentWallpaper}`;
        // Update Config settings
        Config.pauseAutoSave = true;
        Config.updateKey("secondPreviousWallpaper", secondPrev);
        Config.updateKey("previousWallpaper", prev);
        Config.updateKey("currentWallpaper", clean);
        Config.updateKey("wallpaperToSet", clean);
        Config.pauseAutoSave = false;
        // Update ~/.current.wall symlink
        Quickshell.execDetached(["sh", "-c", "ln -sf \"" + clean + "\" ~/.current.wall"]);
        // Run Matugen to regenerate themes
        Quickshell.execDetached(getMatugenArgs(clean));
        Quickshell.execDetached(["notify-send", "Wallpaper & Theme Updated", "New wallpaper and Matugen color palette applied."]);
    }

    function changeColourProp() {
        let clean = cleanWallpaperPath(Config.settings.currentWallpaper);
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
