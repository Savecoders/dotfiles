import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.core
import qs.features
import qs.features.common
import qs.features.settings
import qs.features.settings.content.generics
import qs.services

Item {
    id: root

    property string currentTarget: Config.get("desktop.targetScreen", "all")
    property string selectedMonName: currentTarget
    property var _pendingApply: null
    // Static option lists shared across all monitors
    readonly property var scaleOptions: [{
        "label": "100%",
        "val": 1
    }, {
        "label": "125%",
        "val": 1.25
    }, {
        "label": "150%",
        "val": 1.5
    }, {
        "label": "175%",
        "val": 1.75
    }, {
        "label": "200%",
        "val": 2
    }]
    readonly property var orientationOptions: [{
        "label": "Landscape",
        "val": 0
    }, {
        "label": "Rotated right",
        "val": 1
    }, {
        "label": "Rotated left",
        "val": 3
    }, {
        "label": "Upside down",
        "val": 2
    }]
    readonly property var screenList: {
        let list = [{
            "name": "all",
            "label": "All Displays",
            "isAll": true,
            "res": "All screens",
            "desc": "All connected displays"
        }];
        let mons = (Hyprland.monitorsInfo && Hyprland.monitorsInfo.length > 0) ? Hyprland.monitorsInfo : [];
        if (mons.length > 0) {
            for (let i = 0; i < mons.length; i++) {
                let m = mons[i];
                list.push({
                    "name": m.name || ("Screen " + (i + 1)),
                    "label": m.name || ("Screen " + (i + 1)),
                    "isAll": false,
                    "res": (m.width && m.height ? (m.width + "x" + m.height) : "") + (m.refreshRate ? (" @ " + Number(m.refreshRate).toFixed(0) + "Hz") : ""),
                    "desc": m.description || m.make || "",
                    "raw": m
                });
            }
        } else if (Quickshell.screens) {
            for (let j = 0; j < Quickshell.screens.length; j++) {
                let s = Quickshell.screens[j];
                if (s && s.name)
                    list.push({
                    "name": s.name,
                    "label": s.name,
                    "isAll": false,
                    "res": (s.width && s.height ? (s.width + "x" + s.height) : ""),
                    "desc": "Limited info",
                    "raw": null
                });

            }
        }
        return list;
    }
    // When "all" is selected, return all connected monitors. Otherwise return only the selected one.
    readonly property var displayedMonitors: {
        let mons = (Hyprland.monitorsInfo && Hyprland.monitorsInfo.length > 0) ? Hyprland.monitorsInfo : [];
        if (mons.length === 0)
            return [];

        if (root.selectedMonName === "all")
            return mons;

        let found = mons.find((m) => {
            return m.name === root.selectedMonName;
        });
        return found ? [found] : mons;
    }

    function getFriendlyResName(res) {
        const map = {
            "3840x2160": "4K UHD",
            "2560x1440": "QHD",
            "1920x1200": "WUXGA",
            "1920x1080": "FHD",
            "1680x1050": "WSXGA+",
            "1600x900": "HD+",
            "1440x900": "WXGA+",
            "1366x768": "HD",
            "1280x1024": "SXGA",
            "1280x800": "WXGA",
            "1280x720": "HD",
            "1024x768": "XGA",
            "800x600": "SVGA",
            "640x480": "VGA"
        };
        return map[res] || "";
    }

    // Returns ONLY verified modes supported by the monitor. Falls back to standard list only if no modes reported.
    function resList(m) {
        let seen = ({
        });
        let out = [];
        if (m && m.availableModes && m.availableModes.length > 0) {
            m.availableModes.forEach((s) => {
                let r = s.split("@")[0];
                if (!seen[r]) {
                    seen[r] = true;
                    out.push(r);
                }
            });
            return out;
        }
        const standard = ["1920x1080", "1680x1050", "1280x1024", "1440x900", "1280x800", "1280x720", "1024x768", "800x600", "640x480"];
        return standard;
    }

    function rrList(m, currentRes) {
        let seen = ({
        });
        let out = [];
        if (m && m.availableModes && m.availableModes.length > 0) {
            m.availableModes.forEach((s) => {
                let p = s.split("@");
                if (p[0] === currentRes) {
                    let hzStr = p[1].replace(/Hz$/i, "");
                    let hz = parseFloat(hzStr);
                    let rounded = Math.round(hz * 100) / 100;
                    if (!isNaN(rounded) && !seen[rounded]) {
                        seen[rounded] = true;
                        out.push(rounded);
                    }
                }
            });
        }
        if (out.length === 0) {
            let defHz = (m && m.refreshRate) ? (Math.round(m.refreshRate * 100) / 100) : 60;
            out.push(defHz);
        }
        return out.sort((a, b) => {
            return b - a;
        });
    }

    function applyMonitorInstant(mon, res, hz, scale, transform, vrr) {
        root._pendingApply = {
            "mon": mon,
            "res": res,
            "hz": hz,
            "scale": scale,
            "transform": transform,
            "vrr": vrr
        };
        applyDebounce.restart();
    }

    function _doApplyMonitor(mon, res, hz, scale, transform, vrr) {
        if (!mon || !mon.name)
            return ;

        let pos = (mon.x !== undefined && mon.y !== undefined) ? (mon.x + "x" + mon.y) : "auto";
        let mode = res + "@" + Number(hz).toFixed(0);
        let scaleVal = Number(scale).toFixed(2);
        let transVal = parseInt(transform) || 0;
        let vrrVal = vrr ? 1 : 0;
        let luaEvalStr = `hl.monitor({ output = "${mon.name}", mode = "${mode}", position = "${pos}", scale = ${scaleVal}, transform = ${transVal}, vrr = ${vrrVal} })`;
        let legacyKeywordStr = `${mon.name},${mode},${pos},${scaleVal},transform,${transVal},vrr,${vrrVal}`;
        applyProcess._lastLuaStr = luaEvalStr;
        applyProcess._lastLegacyStr = legacyKeywordStr;
        applyProcess._triedFallback = false;
        // Default to hyprctl eval (modern Hyprland Lua)
        applyProcess.command = ["hyprctl", "eval", luaEvalStr];
        applyProcess.running = false;
        applyProcess.running = true;
    }

    function applyHyprlandGaps(inVal, outVal, wsVal) {
        let inG = inVal !== undefined ? inVal : Config.get("desktop.gapsIn", 4);
        let outG = outVal !== undefined ? outVal : Config.get("desktop.gapsOut", 16);
        let wsG = wsVal !== undefined ? wsVal : Config.get("desktop.workspaceGaps", 0);
        let luaEvalStr = `hl.config({ general = { gaps_in = ${inG}, gaps_out = ${outG}, gaps_workspaces = ${wsG} } })`;
        applyGapsProcess._lastLuaStr = luaEvalStr;
        applyGapsProcess._triedFallback = false;
        applyGapsProcess.command = ["hyprctl", "eval", luaEvalStr];
        applyGapsProcess.running = false;
        applyGapsProcess.running = true;
    }

    onCurrentTargetChanged: {
        if (root.selectedMonName !== root.currentTarget)
            root.selectedMonName = root.currentTarget;

    }

    // Debounced apply to avoid process overlap and rapid hyprctl spam
    Timer {
        id: applyDebounce

        interval: 100
        repeat: false
        onTriggered: {
            if (root._pendingApply) {
                let p = root._pendingApply;
                root._pendingApply = null;
                root._doApplyMonitor(p.mon, p.res, p.hz, p.scale, p.transform, p.vrr);
            }
        }
    }

    Process {
        id: applyProcess

        property bool _triedFallback: false
        property string _lastLuaStr: ""
        property string _lastLegacyStr: ""

        onExited: (exitCode) => {
            if (exitCode !== 0 && !applyProcess._triedFallback && applyProcess._lastLegacyStr !== "") {
                applyProcess._triedFallback = true;
                applyProcess.command = ["hyprctl", "keyword", "monitor", applyProcess._lastLegacyStr];
                applyProcess.running = false;
                applyProcess.running = true;
                return ;
            }
            applyProcess._triedFallback = false;
            Hyprland.updateAll();
        }
    }

    Process {
        id: applyGapsProcess

        property bool _triedFallback: false
        property string _lastLuaStr: ""

        onExited: (exitCode) => {
            if (exitCode !== 0 && !applyGapsProcess._triedFallback) {
                applyGapsProcess._triedFallback = true;
                let inG = Config.get("desktop.gapsIn", 4);
                let outG = Config.get("desktop.gapsOut", 16);
                let wsG = Config.get("desktop.workspaceGaps", 0);
                applyGapsProcess.command = ["bash", "-c", `hyprctl keyword general:gaps_in ${inG} && hyprctl keyword general:gaps_out ${outG} && hyprctl keyword general:gaps_workspaces ${wsG}`];
                applyGapsProcess.running = false;
                applyGapsProcess.running = true;
                return ;
            }
            applyGapsProcess._triedFallback = false;
        }
    }

    Item {
        id: pageWrapper

        width: parent.width - 30
        height: parent.height - 60
        anchors.top: parent.top
        anchors.topMargin: (parent.height / 2) - (height / 2)
        anchors.left: parent.left
        anchors.leftMargin: (parent.width / 2) - (width / 2)

        ScrollView {
            anchors.fill: parent
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                width: pageWrapper.width - 24
                spacing: Styling.spacing.section

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Styling.spacing.md

                    GenericTitle {
                        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                        Layout.preferredHeight: 20
                        Layout.topMargin: 10
                        text: "Desktop & Displays"
                        iconCode: "shelf_auto_hide"
                    }

                    GenericSeperator {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.topMargin: 4
                        Layout.preferredWidth: pageWrapper.width - 24
                        Layout.preferredHeight: 3
                    }

                    // Subtitle / Instruction
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Styling.spacing.xs
                        Layout.topMargin: Styling.spacing.sm

                        RowLayout {
                            spacing: Styling.spacing.md

                            Text {
                                text: "monitor"
                                font.family: Config.settings.iconFont
                                font.pixelSize: 20
                                color: Colours.palette.on_surface
                            }

                            Text {
                                text: "Connected Displays"
                                font.family: Config.settings.font
                                font.pixelSize: Styling.fontSize.title
                                font.weight: Font.Normal
                                color: Colours.palette.on_surface
                            }

                        }

                        Text {
                            Layout.fillWidth: true
                            text: "Select a display to filter options, or choose 'All Displays' to view and configure all screens."
                            font.family: Config.settings.font
                            font.pixelSize: Styling.fontSize.body
                            color: Colours.palette.on_surface_variant
                            wrapMode: Text.WordWrap
                        }

                    }

                    // Horizontal Displays Carousel
                    ListView {
                        id: displaysCarousel

                        Layout.preferredWidth: pageWrapper.width - 24
                        Layout.preferredHeight: 108
                        Layout.topMargin: Styling.spacing.sm
                        orientation: ListView.Horizontal
                        spacing: Styling.spacing.md
                        clip: true
                        model: root.screenList

                        delegate: StyledRect {
                            id: monCard

                            required property var modelData
                            readonly property bool isSelected: root.selectedMonName === monCard.modelData.name
                            readonly property bool isTarget: root.currentTarget === monCard.modelData.name || (root.currentTarget === "" && monCard.modelData.name === "all")
                            property bool hovered: mouseArea.containsMouse

                            variant: "internalbg"
                            useDefaultRadius: true
                            width: 172
                            height: 102
                            color: Colours.palette.surface_container_low
                            border.color: isSelected ? Colours.palette.primary : (hovered ? Colours.palette.outline : Colours.palette.outline_variant)
                            border.width: isSelected ? 2 : 1

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 4

                                // Illustration
                                Item {
                                    Layout.alignment: Qt.AlignHCenter
                                    width: 56
                                    height: 36

                                    // All Displays: Dual monitor illustration
                                    Item {
                                        anchors.fill: parent
                                        visible: monCard.modelData.isAll

                                        StyledRect {
                                            width: 32
                                            height: 22
                                            radius: 4
                                            useDefaultRadius: false
                                            x: 4
                                            y: 4
                                            color: Colours.palette.surface_container_lowest
                                            border.color: monCard.isSelected ? Colours.palette.primary : Colours.palette.outline_variant
                                            border.width: 1
                                        }

                                        StyledRect {
                                            width: 32
                                            height: 22
                                            radius: 4
                                            useDefaultRadius: false
                                            x: 20
                                            y: 8
                                            color: monCard.isTarget ? Colours.palette.primary_container : Colours.palette.surface_container_low
                                            border.color: monCard.isSelected ? Colours.palette.primary : Colours.palette.outline_variant
                                            border.width: 1
                                        }

                                    }

                                    // Single Monitor illustration
                                    Item {
                                        anchors.fill: parent
                                        visible: !monCard.modelData.isAll

                                        StyledRect {
                                            id: screenBody

                                            width: 52
                                            height: 26
                                            radius: 4
                                            useDefaultRadius: false
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            color: monCard.isTarget ? Colours.palette.surface_container_high : Colours.palette.surface_container_lowest
                                            border.color: monCard.isSelected ? Colours.palette.primary : Colours.palette.outline_variant
                                            border.width: 1

                                            Text {
                                                anchors.centerIn: parent
                                                text: monCard.modelData.name
                                                font.family: Config.settings.font
                                                font.pixelSize: Styling.fontSize.caption
                                                font.weight: Font.Bold
                                                color: monCard.isSelected ? Colours.palette.primary : Colours.palette.on_surface_variant
                                                elide: Text.ElideRight
                                                width: parent.width - 4
                                                horizontalAlignment: Text.AlignHCenter
                                            }

                                        }

                                        StyledRect {
                                            id: stem

                                            width: 6
                                            height: 4
                                            radius: 1
                                            useDefaultRadius: false
                                            color: monCard.isSelected ? Colours.palette.primary : Colours.palette.outline_variant
                                            anchors.top: screenBody.bottom
                                            anchors.horizontalCenter: screenBody.horizontalCenter
                                        }

                                        StyledRect {
                                            width: 22
                                            height: 2
                                            radius: 1
                                            useDefaultRadius: false
                                            color: monCard.isSelected ? Colours.palette.primary : Colours.palette.outline_variant
                                            anchors.top: stem.bottom
                                            anchors.horizontalCenter: screenBody.horizontalCenter
                                        }

                                    }

                                }

                                // Labels
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: monCard.modelData.label
                                    font.family: Config.settings.font
                                    font.pixelSize: Styling.fontSize.sm
                                    font.weight: monCard.isSelected ? Font.Bold : Font.Medium
                                    color: Colours.palette.on_surface
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: monCard.modelData.res
                                    font.family: Config.settings.font
                                    font.pixelSize: Styling.fontSize.xs
                                    color: Colours.palette.on_surface_variant
                                    elide: Text.ElideRight
                                }

                            }

                            MouseArea {
                                id: mouseArea

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.selectedMonName = monCard.modelData.name;
                                    if (monCard.modelData.isAll)
                                        Config.updateKey("desktop.targetScreen", "all");
                                    else
                                        Config.updateKey("desktop.targetScreen", monCard.modelData.name);
                                }
                            }

                            Behavior on border.color {
                                PropertyAnimation {
                                    duration: Config.settings.animationSpeed ?? 150
                                    easing.type: Easing.OutQuad
                                }

                            }

                        }

                    }

                }

                Text {
                    visible: root.displayedMonitors.length === 0
                    Layout.fillWidth: true
                    Layout.topMargin: Styling.spacing.lg
                    Layout.bottomMargin: Styling.spacing.lg
                    text: "Waiting for display information from Hyprland..."
                    font.family: Config.settings.font
                    font.pixelSize: Styling.fontSize.md
                    color: Colours.palette.on_surface_variant
                    horizontalAlignment: Text.AlignHCenter
                }

                Repeater {
                    model: root.displayedMonitors

                    ColumnLayout {
                        id: monSection

                        required property var modelData
                        required property int index
                        readonly property string activeRes: monSection.modelData.width + "x" + monSection.modelData.height
                        property string curRes: monSection.activeRes
                        property real curHz: (monSection.modelData.refreshRate && !isNaN(monSection.modelData.refreshRate)) ? (Math.round(monSection.modelData.refreshRate * 100) / 100) : 60
                        property real curScale: monSection.modelData.scale || 1
                        property int curTransform: monSection.modelData.transform || 0
                        property bool curVrr: !!monSection.modelData.vrr

                        Layout.fillWidth: true
                        spacing: Styling.spacing.lg

                        // Monitor Title Header
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Styling.spacing.xs

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Styling.spacing.md

                                Text {
                                    text: "desktop_windows"
                                    font.family: Config.settings.iconFont
                                    font.pixelSize: 22
                                    color: Colours.palette.primary
                                }

                                Text {
                                    text: monSection.modelData.name + (monSection.modelData.description ? (" • " + monSection.modelData.description) : (monSection.modelData.make ? (" • " + monSection.modelData.make) : ""))
                                    font.family: Config.settings.font
                                    font.pixelSize: Styling.fontSize.title
                                    font.weight: Font.Normal
                                    color: Colours.palette.on_surface
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                StyledRect {
                                    variant: "internalbg"
                                    useDefaultRadius: true
                                    Layout.preferredWidth: 84
                                    Layout.preferredHeight: 28
                                    color: monSection.modelData.focused ? Colours.palette.primary_container : Colours.palette.surface_container_low
                                    border.color: monSection.modelData.focused ? Colours.palette.primary : Colours.palette.outline_variant
                                    border.width: 1

                                    Text {
                                        anchors.centerIn: parent
                                        text: monSection.modelData.focused ? "Focused" : "Connected"
                                        font.family: Config.settings.font
                                        font.pixelSize: Styling.fontSize.xs
                                        font.weight: Font.Normal
                                        color: monSection.modelData.focused ? Colours.palette.on_primary_container : Colours.palette.on_surface_variant
                                    }

                                }

                            }

                            Text {
                                Layout.fillWidth: true
                                text: "Active: " + (monSection.modelData.width || "?") + "x" + (monSection.modelData.height || "?") + " @ " + ((monSection.modelData.refreshRate && !isNaN(monSection.modelData.refreshRate)) ? Number(monSection.modelData.refreshRate).toFixed(0) : "?") + " Hz • Scale: " + ((monSection.modelData.scale && !isNaN(monSection.modelData.scale)) ? Number(monSection.modelData.scale).toFixed(2) : "1.00") + "x"
                                font.family: Config.settings.font
                                font.pixelSize: Styling.fontSize.body
                                color: Colours.palette.on_surface_variant
                            }

                        }

                        GenericSeperator {
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Layout.topMargin: 2
                            Layout.preferredWidth: pageWrapper.width - 24
                            Layout.preferredHeight: 2
                        }

                        // Resolution Grid (Supported modes only)
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Styling.spacing.sm

                            Text {
                                text: "Resolution"
                                font.family: Config.settings.font
                                font.pixelSize: Styling.fontSize.md
                                font.weight: Font.Normal
                                color: Colours.palette.on_surface
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                columns: 2
                                columnSpacing: Styling.spacing.lg
                                rowSpacing: Styling.spacing.md

                                Repeater {
                                    model: root.resList(monSection.modelData)

                                    SelectablePill {
                                        id: resPill

                                        required property string modelData
                                        readonly property string friendly: root.getFriendlyResName(resPill.modelData)

                                        isSelected: monSection.curRes === resPill.modelData
                                        Layout.preferredHeight: 38
                                        onActivated: {
                                            monSection.curRes = resPill.modelData;
                                            let rates = root.rrList(monSection.modelData, resPill.modelData);
                                            if (rates.length > 0)
                                                monSection.curHz = rates[0];

                                            root.applyMonitorInstant(monSection.modelData, resPill.modelData, monSection.curHz, monSection.curScale, monSection.curTransform, monSection.curVrr);
                                        }

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 16
                                            anchors.rightMargin: 18
                                            spacing: 8

                                            Text {
                                                text: resPill.friendly.length > 0 ? resPill.friendly : resPill.modelData
                                                font.family: Config.settings.font
                                                font.pixelSize: Styling.fontSize.sm
                                                font.weight: resPill.isSelected ? Font.Medium : Font.Normal
                                                color: Colours.palette.primary
                                            }

                                            Item {
                                                Layout.fillWidth: true
                                            }

                                            Text {
                                                text: resPill.modelData
                                                font.family: Config.settings.font
                                                font.pixelSize: Styling.fontSize.md
                                                color: resPill.isSelected ? Colours.palette.primary : Colours.palette.on_surface_variant
                                            }

                                        }

                                    }

                                }

                            }

                        }

                        // Refresh Rate
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Styling.spacing.sm
                            Layout.topMargin: Styling.spacing.sm

                            Text {
                                text: "Refresh Rate"
                                font.family: Config.settings.font
                                font.pixelSize: Styling.fontSize.md
                                font.weight: Font.Normal
                                color: Colours.palette.on_surface
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Styling.spacing.md

                                Repeater {
                                    model: root.rrList(monSection.modelData, monSection.curRes)

                                    SelectablePill {
                                        id: hzPill

                                        required property real modelData

                                        isSelected: Math.abs(monSection.curHz - hzPill.modelData) < 0.01
                                        Layout.preferredHeight: 34
                                        onActivated: {
                                            monSection.curHz = hzPill.modelData;
                                            root.applyMonitorInstant(monSection.modelData, monSection.curRes, monSection.curHz, monSection.curScale, monSection.curTransform, monSection.curVrr);
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: Number(hzPill.modelData).toFixed(0) + " Hz" + (hzPill.modelData % 1 !== 0 ? (" (" + Number(hzPill.modelData).toFixed(2) + ")") : "")
                                            font.family: Config.settings.font
                                            font.pixelSize: Styling.fontSize.sm
                                            font.weight: hzPill.isSelected ? Font.Medium : Font.Normal
                                            color: hzPill.isSelected ? Colours.palette.primary : Colours.palette.on_surface
                                        }

                                    }

                                }

                            }

                        }

                        // Scale Section
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Styling.spacing.sm
                            Layout.topMargin: Styling.spacing.sm

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Styling.spacing.lg

                                Text {
                                    text: "Scale"
                                    font.family: Config.settings.font
                                    font.pixelSize: Styling.fontSize.md
                                    font.weight: Font.Normal
                                    color: Colours.palette.on_surface
                                    Layout.preferredWidth: 100
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: Styling.spacing.md

                                    Repeater {
                                        model: root.scaleOptions

                                        SelectablePill {
                                            id: scalePill

                                            required property var modelData

                                            isSelected: Math.abs(monSection.curScale - scalePill.modelData.val) < 0.01
                                            Layout.preferredHeight: 34
                                            onActivated: {
                                                monSection.curScale = scalePill.modelData.val;
                                                root.applyMonitorInstant(monSection.modelData, monSection.curRes, monSection.curHz, monSection.curScale, monSection.curTransform, monSection.curVrr);
                                            }

                                            Text {
                                                anchors.centerIn: parent
                                                text: scalePill.modelData.label
                                                font.family: Config.settings.font
                                                font.pixelSize: Styling.fontSize.sm
                                                font.weight: scalePill.isSelected ? Font.Medium : Font.Normal
                                                color: scalePill.isSelected ? Colours.palette.primary : Colours.palette.on_surface
                                            }

                                        }

                                    }

                                }

                            }

                        }

                        // Orientation Section
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Styling.spacing.lg
                            Layout.topMargin: Styling.spacing.sm

                            Text {
                                text: "Orientation"
                                font.family: Config.settings.font
                                font.pixelSize: Styling.fontSize.md
                                font.weight: Font.Normal
                                color: Colours.palette.on_surface
                                Layout.preferredWidth: 100
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Styling.spacing.md

                                Repeater {
                                    model: root.orientationOptions

                                    SelectablePill {
                                        id: orientPill

                                        required property var modelData

                                        isSelected: monSection.curTransform === orientPill.modelData.val
                                        Layout.preferredHeight: 34
                                        onActivated: {
                                            monSection.curTransform = orientPill.modelData.val;
                                            root.applyMonitorInstant(monSection.modelData, monSection.curRes, monSection.curHz, monSection.curScale, monSection.curTransform, monSection.curVrr);
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: orientPill.modelData.label
                                            font.family: Config.settings.font
                                            font.pixelSize: Styling.fontSize.sm
                                            font.weight: orientPill.isSelected ? Font.Medium : Font.Normal
                                            color: orientPill.isSelected ? Colours.palette.primary : Colours.palette.on_surface
                                        }

                                    }

                                }

                            }

                        }

                        // Variable Refresh Rate (VRR)
                        GenericToggleOption {
                            Layout.topMargin: Styling.spacing.sm
                            message: "Variable refresh rate (Adaptive Sync / VRR)"
                            option: monSection.curVrr
                            toRun: () => {
                                monSection.curVrr = !monSection.curVrr;
                                root.applyMonitorInstant(monSection.modelData, monSection.curRes, monSection.curHz, monSection.curScale, monSection.curTransform, monSection.curVrr);
                                return monSection.curVrr;
                            }
                            withIcon: true
                            iconCode: "speed"
                        }

                    }

                }

                // Window & Workspace Gaps Section
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Styling.spacing.md

                    GenericTitle {
                        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                        Layout.preferredHeight: 20
                        Layout.topMargin: Styling.spacing.sm
                        text: "Window & Workspace Gaps"
                        iconCode: "space_dashboard"
                    }

                    GenericSeperator {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.topMargin: 4
                        Layout.preferredWidth: pageWrapper.width - 24
                        Layout.preferredHeight: 3
                    }

                    GenericNumberOption {
                        message: "Inner gaps (between windows)"
                        value: Config.get("desktop.gapsIn", 4)
                        maxValue: 32
                        minValue: 0
                        amountIncrease: () => {
                            let cur = Config.get("desktop.gapsIn", 4);
                            if (cur < 32) {
                                let nextVal = cur + 1;
                                Config.updateKey("desktop.gapsIn", nextVal);
                                root.applyHyprlandGaps(nextVal, undefined, undefined);
                            }
                        }
                        amountDecrease: () => {
                            let cur = Config.get("desktop.gapsIn", 4);
                            if (cur > 0) {
                                let nextVal = cur - 1;
                                Config.updateKey("desktop.gapsIn", nextVal);
                                root.applyHyprlandGaps(nextVal, undefined, undefined);
                            }
                        }
                        isFloat: false
                        withIcon: true
                        iconCode: "splitscreen"
                    }

                    GenericNumberOption {
                        message: "Outer gaps (between windows & screen edge)"
                        value: Config.get("desktop.gapsOut", 16)
                        maxValue: 64
                        minValue: 0
                        amountIncrease: () => {
                            let cur = Config.get("desktop.gapsOut", 16);
                            if (cur < 64) {
                                let nextVal = cur + 2;
                                Config.updateKey("desktop.gapsOut", nextVal);
                                root.applyHyprlandGaps(undefined, nextVal, undefined);
                            }
                        }
                        amountDecrease: () => {
                            let cur = Config.get("desktop.gapsOut", 16);
                            if (cur > 0) {
                                let nextVal = Math.max(0, cur - 2);
                                Config.updateKey("desktop.gapsOut", nextVal);
                                root.applyHyprlandGaps(undefined, nextVal, undefined);
                            }
                        }
                        isFloat: false
                        withIcon: true
                        iconCode: "border_outer"
                    }

                    GenericNumberOption {
                        message: "Workspace gaps (gap between workspaces)"
                        value: Config.get("desktop.workspaceGaps", 0)
                        maxValue: 64
                        minValue: 0
                        amountIncrease: () => {
                            let cur = Config.get("desktop.workspaceGaps", 0);
                            if (cur < 64) {
                                let nextVal = cur + 2;
                                Config.updateKey("desktop.workspaceGaps", nextVal);
                                root.applyHyprlandGaps(undefined, undefined, nextVal);
                            }
                        }
                        amountDecrease: () => {
                            let cur = Config.get("desktop.workspaceGaps", 0);
                            if (cur > 0) {
                                let nextVal = Math.max(0, cur - 2);
                                Config.updateKey("desktop.workspaceGaps", nextVal);
                                root.applyHyprlandGaps(undefined, undefined, nextVal);
                            }
                        }
                        isFloat: false
                        withIcon: true
                        iconCode: "view_carousel"
                    }

                }

                // Desktop Appearance Section
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Styling.spacing.md

                    GenericTitle {
                        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                        Layout.preferredHeight: 20
                        Layout.topMargin: Styling.spacing.sm
                        text: "Desktop Appearance"
                        iconCode: "palette"
                    }

                    GenericSeperator {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.topMargin: 4
                        Layout.preferredWidth: pageWrapper.width - 24
                        Layout.preferredHeight: 3
                    }

                    GenericToggleOption {
                        message: "Show a rounded desktop border"
                        option: Config.get("desktop.desktopRoundingShown", true)
                        toRun: () => {
                            let val = !Config.get("desktop.desktopRoundingShown", true);
                            Config.updateKey("desktop.desktopRoundingShown", val);
                            return val;
                        }
                        withIcon: true
                        iconCode: "capture"
                    }

                    GenericNumberOption {
                        visible: Config.get("desktop.desktopRoundingShown", true)
                        message: "Desktop screen border gap (outer cutout px)"
                        value: Config.get("desktop.desktopGap", 4)
                        maxValue: 24
                        minValue: 0
                        amountIncrease: () => {
                            let cur = Config.get("desktop.desktopGap", 4);
                            if (cur < 24)
                                Config.updateKey("desktop.desktopGap", cur + 1);

                        }
                        amountDecrease: () => {
                            let cur = Config.get("desktop.desktopGap", 4);
                            if (cur > 0)
                                Config.updateKey("desktop.desktopGap", cur - 1);

                        }
                        isFloat: false
                        withIcon: true
                        iconCode: "margin"
                    }

                    GenericToggleOption {
                        message: "Dim the wallpaper"
                        option: Config.get("desktop.dimDesktopWallpaper", false)
                        toRun: () => {
                            let val = !Config.get("desktop.dimDesktopWallpaper", false);
                            Config.updateKey("desktop.dimDesktopWallpaper", val);
                            return val;
                        }
                        withIcon: true
                        iconCode: "brightness_6"
                    }

                }

            }

        }

    }

    // Reusable Selectable Pill Component
    component SelectablePill: StyledRect {
        id: pill

        property bool isSelected: false
        property bool hovered: mouseArea.containsMouse
        property bool pressed: mouseArea.pressed

        signal activated()

        variant: "internalbg"
        useDefaultRadius: true
        Layout.fillWidth: true
        scale: pressed ? 0.98 : 1
        color: Colours.palette.surface_container_low
        border.color: isSelected ? Colours.palette.primary : (hovered ? Colours.palette.outline : Colours.palette.outline_variant)
        border.width: isSelected ? 2 : 1

        MouseArea {
            id: mouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: pill.activated()
        }

        Behavior on border.color {
            PropertyAnimation {
                duration: Config.settings.animationSpeed ?? 150
                easing.type: Easing.OutQuad
            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: 80
                easing.type: Easing.OutQuad
            }

        }

    }

}
