import QtQuick
import Quickshell
import qs.core
pragma Singleton

Singleton {
    id: root

    property bool visible: false
    property string text: ""
    property real globalX: 0
    property real globalY: 0
    property real targetWidth: 0
    property real targetHeight: 0
    property var targetScreen: null
    property string preferredPos: "top"

    function show(textStr, gx, gy, w, h, screenObj, pos) {
        if (!textStr || textStr === "") {
            hide();
            return ;
        }
        root.text = textStr;
        root.globalX = gx;
        root.globalY = gy;
        root.targetWidth = w || 0;
        root.targetHeight = h || 0;
        root.targetScreen = screenObj || null;
        root.preferredPos = pos || "top";
        delayTimer.restart();
    }

    function showItem(item, textStr, pos) {
        if (!item || !textStr || textStr === "") {
            hide();
            return ;
        }
        let win = item.Window ? item.Window.window : null;
        let pt = item.mapToItem(null, 0, 0);
        let winX = 0;
        let winY = 0;
        let scr = win ? win.screen : null;
        let scrW = (scr && scr.width) ? scr.width : 1920;
        let scrH = (scr && scr.height) ? scr.height : 1080;
        let barPos = Config.barPosition;
        if (win) {
            if (barPos === "bottom")
                winY = scrH - win.height;
            else if (barPos === "right")
                winX = scrW - win.width;
        }
        let gx = winX + pt.x;
        let gy = winY + pt.y;
        show(textStr, gx, gy, item.width, item.height, scr, pos || (barPos === "bottom" ? "top" : "bottom"));
    }

    function hide() {
        delayTimer.stop();
        root.visible = false;
        root.text = "";
    }

    Timer {
        id: delayTimer

        interval: 180
        repeat: false
        onTriggered: {
            root.visible = true;
        }
    }

}
