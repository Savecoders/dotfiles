import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls
import Quickshell.Widgets
import qs.features.settings
import qs.features.settings.content
import qs.features.settings.content.generics
import qs.core
import qs.features.common
import qs.features
import qs.services

Rectangle {
    id: root

    color: "transparent"

    Rectangle {
        id: pageWrapper

        width: parent.width - 30
        height: parent.height - 60
        anchors.top: parent.top
        anchors.topMargin: (parent.height / 2) - (height / 2)
        anchors.left: parent.left
        anchors.leftMargin: (parent.width / 2) - (width / 2)
        color: "transparent"

        ScrollView {
            anchors.fill: parent
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                width: pageWrapper.width - 20
                spacing: 10

                GenericTitle {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    Layout.preferredHeight: 20
                    Layout.topMargin: 10
                    text: "Bar Layout & Position"
                    iconCode: "bottom_navigation"
                }

                GenericSeperator {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.topMargin: 5
                    Layout.preferredWidth: pageWrapper.width
                    Layout.preferredHeight: 3
                }

                GenericSelectOption {
                    message: "Bar position"
                    options: ["left", "right", "top", "bottom"]
                    currentIndex: ["left", "right", "top", "bottom"].indexOf(Config.settings.bar.position)
                    toRun: (index) => {
                        let val = ["left", "right", "top", "bottom"][index];
                        Config.settings.bar.position = val;
                        Config.updateKey("bar.position", val);
                    }
                    withIcon: true
                    iconCode: "align_justify_stretch"
                }

                GenericToggleOption {
                    message: "Show smooth edges around bar"
                    option: Config.settings.bar.smoothEdgesShown
                    toRun: () => {
                        Config.settings.bar.smoothEdgesShown = !Config.settings.bar.smoothEdgesShown;
                        Config.updateKey("bar.smoothEdgesShown", Config.settings.bar.smoothEdgesShown);
                        return Config.settings.bar.smoothEdgesShown;
                    }
                    withIcon: true
                    iconCode: "line_curve"
                }

                GenericToggleOption {
                    message: "Expand bar to full length"
                    option: Config.settings.bar.expand
                    toRun: () => {
                        Config.settings.bar.expand = !Config.settings.bar.expand;
                        Config.updateKey("bar.expand", Config.settings.bar.expand);
                        return Config.settings.bar.expand;
                    }
                    withIcon: true
                    iconCode: "aspect_ratio"
                }

                GenericToggleOption {
                    message: "Center workspaces in bar"
                    option: Config.settings.bar.workspacesCenterAligned
                    toRun: () => {
                        Config.settings.bar.workspacesCenterAligned = !Config.settings.bar.workspacesCenterAligned;
                        Config.updateKey("bar.workspacesCenterAligned", Config.settings.bar.workspacesCenterAligned);
                        return Config.settings.bar.workspacesCenterAligned;
                    }
                    withIcon: true
                    iconCode: "align_vertical_center"
                }

                GenericTitle {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    Layout.preferredHeight: 25
                    Layout.topMargin: 25
                    text: "Transparency & Margins"
                    iconCode: "opacity"
                }

                GenericSeperator {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.topMargin: 5
                    Layout.preferredWidth: pageWrapper.width
                    Layout.preferredHeight: 3
                }

                GenericNumberOption {
                    message: "Bar opacity (transparency)"
                    value: (Config.settings.bar.opacity !== undefined ? Config.settings.bar.opacity : 0.95)
                    maxValue: 1
                    minValue: 0.1
                    amountIncrease: () => {
                        let cur = Config.settings.bar.opacity !== undefined ? Config.settings.bar.opacity : 0.95;
                        if (cur < 1) {
                            let nextVal = Math.min(1, parseFloat((cur + 0.05).toFixed(2)));
                            Config.settings.bar.opacity = nextVal;
                            Config.updateKey("bar.opacity", nextVal);
                        }
                    }
                    amountDecrease: () => {
                        let cur = Config.settings.bar.opacity !== undefined ? Config.settings.bar.opacity : 0.95;
                        if (cur > 0.1) {
                            let nextVal = Math.max(0.1, parseFloat((cur - 0.05).toFixed(2)));
                            Config.settings.bar.opacity = nextVal;
                            Config.updateKey("bar.opacity", nextVal);
                        }
                    }
                    isFloat: true
                    withIcon: true
                    iconCode: "opacity"
                }

                GenericNumberOption {
                    message: "Bar edge margin (gap px)"
                    value: Config.settings.bar.margin !== undefined ? Config.settings.bar.margin : 10
                    maxValue: 20
                    minValue: 0
                    amountIncrease: () => {
                        let cur = Config.settings.bar.margin !== undefined ? Config.settings.bar.margin : 10;
                        if (cur < 20) {
                            Config.settings.bar.margin = cur + 1;
                            Config.updateKey("bar.margin", cur + 1);
                        }
                    }
                    amountDecrease: () => {
                        let cur = Config.settings.bar.margin !== undefined ? Config.settings.bar.margin : 10;
                        if (cur > 0) {
                            Config.settings.bar.margin = cur - 1;
                            Config.updateKey("bar.margin", cur - 1);
                        }
                    }
                    isFloat: false
                    withIcon: true
                    iconCode: "fullscreen"
                }

                GenericTitle {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    Layout.preferredHeight: 25
                    Layout.topMargin: 25
                    text: "Branding & PFP"
                    iconCode: "account_circle"
                }

                GenericSeperator {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.topMargin: 5
                    Layout.preferredWidth: pageWrapper.width
                    Layout.preferredHeight: 3
                }

                GenericToggleOption {
                    message: "Show profile picture instead of icon"
                    option: Config.settings.usePfpInsteadOfLogo
                    toRun: () => {
                        Config.settings.usePfpInsteadOfLogo = !Config.settings.usePfpInsteadOfLogo;
                        Config.updateKey("usePfpInsteadOfLogo", Config.settings.usePfpInsteadOfLogo);
                        return Config.settings.usePfpInsteadOfLogo;
                    }
                    withIcon: true
                    iconCode: "account_circle"
                }

                GenericTextOption {
                    message: "Profile Picture (PFP) path"
                    textValue: Config.settings.pfpLocation
                    toRun: (text) => {
                        Config.settings.pfpLocation = text;
                        Config.updateKey("pfpLocation", text);
                        return text;
                    }
                    withIcon: true
                    iconCode: "account_box"
                }

                GenericTitle {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    Layout.preferredHeight: 25
                    Layout.topMargin: 25
                    text: "Custom Page"
                    iconCode: "dashboard"
                }

                GenericSeperator {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.topMargin: 5
                    Layout.preferredWidth: pageWrapper.width
                    Layout.preferredHeight: 3
                }

                Rectangle {
                    id: customPageCard

                    Layout.preferredWidth: pageWrapper.width - 20
                    Layout.preferredHeight: widgetReorderColumn.implicitHeight + 40
                    Layout.topMargin: 10
                    radius: Config.settings.borderRadius
                    color: Colours.palette.surface_container
                    border.width: 1
                    border.color: Colours.palette.outline_variant

                    Item {
                        id: widgetReorder

                        // Drag state
                        property bool dragActive: false
                        property string dragWidgetId: ""
                        property bool dragFromSelection: false
                        property int dragSelectedIndex: -1
                        property real dragX: 0
                        property real dragY: 0
                        property real dragPointerOffsetX: 0
                        property real dragPointerOffsetY: 0
                        property string dragZone: ""
                        readonly property bool dragPreviewUsesBarStyle: dragFromSelection && dragZone === "bar"
                        readonly property int selectedSpacing: 8

                        function containsSelected(widgetId) {
                            const norm = String(widgetId || "").toLowerCase();
                            for (let i = 0; i < selectedModel.count; i++) {
                                if (selectedModel.get(i).widgetId === norm)
                                    return true;

                            }
                            return false;
                        }

                        function loadFromConfig() {
                            const raw = Config.settings.bar.rightWidgets || ["systray", "recording", "notifications", "quickactions"];
                            selectedModel.clear();
                            const seen = {
                            };
                            for (let i = 0; i < raw.length; i++) {
                                const wId = String(raw[i]).toLowerCase();
                                if (BarWidgets.definitionForId(wId) && !seen[wId]) {
                                    selectedModel.append({
                                        "widgetId": wId
                                    });
                                    seen[wId] = true;
                                }
                            }
                        }

                        function notifyChanged() {
                            const ids = [];
                            for (let i = 0; i < selectedModel.count; i++) ids.push(selectedModel.get(i).widgetId)
                            Config.settings.bar.rightWidgets = ids;
                            Config.updateKey("bar.rightWidgets", ids);
                        }

                        function addItem(widgetId, targetIndex) {
                            const norm = String(widgetId || "").toLowerCase();
                            if (!BarWidgets.definitionForId(norm) || containsSelected(norm))
                                return ;

                            const insertIndex = Math.max(0, Math.min(selectedModel.count, targetIndex));
                            selectedModel.insert(insertIndex, {
                                "widgetId": norm
                            });
                            notifyChanged();
                        }

                        function moveItem(fromIndex, targetIndex) {
                            if (fromIndex < 0 || fromIndex >= selectedModel.count)
                                return ;

                            const boundedTarget = Math.max(0, Math.min(selectedModel.count, targetIndex));
                            const nextIndex = fromIndex < boundedTarget ? boundedTarget - 1 : boundedTarget;
                            if (fromIndex === nextIndex)
                                return ;

                            selectedModel.move(fromIndex, nextIndex, 1);
                            notifyChanged();
                        }

                        function removeItem(index) {
                            if (index < 0 || index >= selectedModel.count)
                                return ;

                            selectedModel.remove(index, 1);
                            notifyChanged();
                        }

                        function containsRootPoint(item, rootX, rootY) {
                            if (!item)
                                return false;

                            const point = widgetReorder.mapToItem(item, rootX, rootY);
                            return point.x >= 0 && point.x <= item.width && point.y >= 0 && point.y <= item.height;
                        }

                        function refreshDragZone(rootX, rootY) {
                            if (containsRootPoint(paletteZone, rootX, rootY))
                                dragZone = "palette";
                            else if (containsRootPoint(barPreview, rootX, rootY))
                                dragZone = "bar";
                            else
                                dragZone = "outside";
                        }

                        function beginDrag(sourceChip, mouseX, mouseY) {
                            const point = sourceChip.mapToItem(widgetReorder, mouseX, mouseY);
                            dragWidgetId = sourceChip.widgetId;
                            dragFromSelection = sourceChip.fromSelection;
                            dragSelectedIndex = sourceChip.selectedIndex;
                            dragPointerOffsetX = mouseX;
                            dragPointerOffsetY = mouseY;
                            dragActive = true;
                            updateDrag(sourceChip, mouseX, mouseY);
                        }

                        function updateDrag(sourceChip, mouseX, mouseY) {
                            const point = sourceChip.mapToItem(widgetReorder, mouseX, mouseY);
                            dragX = point.x - dragPointerOffsetX;
                            dragY = point.y - dragPointerOffsetY;
                            const rootX = dragX + dragPointerOffsetX;
                            const rootY = dragY + dragPointerOffsetY;
                            refreshDragZone(rootX, rootY);
                        }

                        function finishDrag() {
                            const wasFromSelection = dragFromSelection;
                            const sourceIndex = dragSelectedIndex;
                            const sourceId = dragWidgetId;
                            const rootX = dragX + dragPointerOffsetX;
                            const rootY = dragY + dragPointerOffsetY;
                            if (containsRootPoint(barPreview, rootX, rootY)) {
                                const barPoint = widgetReorder.mapToItem(barPreview, rootX, rootY);
                                const targetIndex = targetIndexForBarX(barPoint.x, wasFromSelection ? sourceIndex : -1);
                                if (wasFromSelection)
                                    moveItem(sourceIndex, targetIndex);
                                else
                                    addItem(sourceId, targetIndex);
                            } else {
                                if (wasFromSelection)
                                    removeItem(sourceIndex);

                            }
                            clearDrag();
                        }

                        function clearDrag() {
                            dragActive = false;
                            dragWidgetId = "";
                            dragFromSelection = false;
                            dragSelectedIndex = -1;
                            dragZone = "";
                        }

                        function isDraggingSelection(index) {
                            return dragActive && dragFromSelection && dragSelectedIndex === index;
                        }

                        function selectedContentWidth(excludedIndex) {
                            let total = 0;
                            let count = 0;
                            for (let i = 0; i < selectedModel.count; i++) {
                                if (i === excludedIndex)
                                    continue;

                                total += BarWidgets.previewWidth(selectedModel.get(i).widgetId);
                                count++;
                            }
                            if (count > 1)
                                total += selectedSpacing * (count - 1);

                            return total;
                        }

                        function targetIndexForBarX(localX, excludedIndex) {
                            const contentWidth = selectedContentWidth(excludedIndex);
                            let cursorX = (barPreview.width - contentWidth) / 2;
                            for (let i = 0; i < selectedModel.count; i++) {
                                if (i === excludedIndex)
                                    continue;

                                const itemWidth = BarWidgets.previewWidth(selectedModel.get(i).widgetId);
                                if (localX < cursorX + itemWidth / 2)
                                    return i;

                                cursorX += itemWidth + selectedSpacing;
                            }
                            return selectedModel.count;
                        }

                        anchors.fill: parent
                        anchors.margins: 20
                        Component.onCompleted: loadFromConfig()

                        ListModel {
                            id: selectedModel
                        }

                        Column {
                            id: widgetReorderColumn

                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: 24

                            // Top: Palette
                            Item {
                                id: paletteZone

                                width: parent.width
                                implicitHeight: paletteFlow.implicitHeight

                                Flow {
                                    id: paletteFlow

                                    width: parent.width
                                    spacing: 10

                                    Repeater {
                                        model: BarWidgets.definitions

                                        WidgetChip {
                                            widgetId: modelData.widgetId
                                            fromSelection: false
                                            selectedIndex: -1
                                            paletteDisabled: widgetReorder.containsSelected(modelData.widgetId)
                                        }

                                    }

                                }

                            }

                            // Bottom: Bar Preview Stage
                            Item {
                                id: barStage

                                width: parent.width
                                implicitHeight: 80

                                Rectangle {
                                    id: barPreview

                                    readonly property real wantedWidth: selectedModel.count > 0 ? widgetReorder.selectedContentWidth(widgetReorder.dragFromSelection ? widgetReorder.dragSelectedIndex : -1) + 40 : 200

                                    anchors.centerIn: parent
                                    width: Math.min(parent.width - 40, Math.max(200, wantedWidth))
                                    height: 48
                                    radius: Config.settings.borderRadius
                                    color: Colours.palette.surface_container_high
                                    border.width: 1.5
                                    border.color: Colours.palette.outline

                                    Text {
                                        anchors.centerIn: parent
                                        visible: selectedModel.count === 0
                                        text: "+"
                                        font.family: Config.settings.font
                                        font.pixelSize: 22
                                        font.weight: Font.DemiBold
                                        color: Qt.alpha(Colours.palette.on_surface, 0.4)
                                    }

                                    Row {
                                        id: selectedRow

                                        visible: selectedModel.count > 0
                                        anchors.centerIn: parent
                                        height: 36
                                        spacing: widgetReorder.selectedSpacing

                                        Repeater {
                                            model: selectedModel

                                            Item {
                                                id: selectedSlot

                                                width: widgetReorder.isDraggingSelection(index) ? 0 : selectedChip.width
                                                height: selectedChip.height

                                                WidgetChip {
                                                    id: selectedChip

                                                    widgetId: model.widgetId
                                                    fromSelection: true
                                                    selectedIndex: index
                                                }

                                                Behavior on width {
                                                    NumberAnimation {
                                                        duration: 180
                                                        easing.type: Easing.OutCubic
                                                    }

                                                }

                                            }

                                        }

                                    }

                                    Behavior on width {
                                        NumberAnimation {
                                            duration: 200
                                            easing.type: Easing.OutCubic
                                        }

                                    }

                                }

                            }

                        }

                        // ── FLOATING DRAG PREVIEW ──
                        WidgetChip {
                            id: dragPreview

                            visible: widgetReorder.dragActive
                            widgetId: widgetReorder.dragWidgetId
                            fromSelection: widgetReorder.dragPreviewUsesBarStyle
                            floating: true
                            interactive: false
                            x: widgetReorder.dragX
                            y: widgetReorder.dragY
                            z: 10000
                            opacity: 0.95
                        }

                        // ── INLINE COMPONENT: WIDGET CHIP ──
                        component WidgetChip: Rectangle {
                            id: chip

                            property string widgetId: ""
                            property bool fromSelection: false
                            property bool paletteDisabled: false
                            property bool floating: false
                            property bool interactive: true
                            property int selectedIndex: -1
                            readonly property var def: BarWidgets.definitionForId(widgetId)
                            readonly property bool draggable: interactive && (fromSelection || !paletteDisabled)
                            readonly property bool hiddenByDrag: widgetReorder.dragActive && widgetReorder.dragWidgetId === widgetId && widgetReorder.dragFromSelection === fromSelection && (!fromSelection || widgetReorder.dragSelectedIndex === selectedIndex)

                            width: def ? def.previewWidth : 60
                            height: 34
                            radius: 8
                            color: fromSelection ? Colours.palette.primary_container : (draggable && chipMouse.containsMouse ? Colours.palette.surface_container_highest : Colours.palette.surface_container)
                            border.width: fromSelection ? 0 : 1
                            border.color: chipMouse.containsMouse ? Colours.palette.primary : Colours.palette.outline_variant
                            opacity: hiddenByDrag ? 0 : (paletteDisabled ? 0.35 : 1)
                            z: widgetReorder.dragActive && hiddenByDrag ? 0 : 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 5

                                Repeater {
                                    model: chip.def && chip.def.previewIcons ? chip.def.previewIcons : (chip.def && chip.def.previewIcon ? [chip.def.previewIcon] : [])

                                    Text {
                                        text: modelData
                                        font.family: Config.settings.iconFont
                                        font.pixelSize: 14
                                        color: chip.fromSelection ? Colours.palette.on_primary_container : Colours.palette.primary
                                    }

                                }

                                Text {
                                    text: chip.def ? (chip.def.previewText || chip.def.displayName) : chip.widgetId
                                    font.family: Config.settings.font
                                    font.pixelSize: 12
                                    font.weight: 600
                                    color: chip.fromSelection ? Colours.palette.on_primary_container : Colours.palette.on_surface
                                    elide: Text.ElideRight
                                }

                            }

                            MouseArea {
                                id: chipMouse

                                property real pressX: 0
                                property real pressY: 0
                                property bool dragStarted: false

                                anchors.fill: parent
                                enabled: chip.draggable
                                hoverEnabled: true
                                preventStealing: true
                                cursorShape: chip.draggable ? Qt.OpenHandCursor : Qt.ArrowCursor
                                onPressed: function(mouse) {
                                    pressX = mouse.x;
                                    pressY = mouse.y;
                                    dragStarted = false;
                                    cursorShape = Qt.ClosedHandCursor;
                                }
                                onPositionChanged: function(mouse) {
                                    if (!pressed)
                                        return ;

                                    const dx = mouse.x - pressX;
                                    const dy = mouse.y - pressY;
                                    if (!dragStarted && Math.sqrt(dx * dx + dy * dy) >= 4) {
                                        dragStarted = true;
                                        widgetReorder.beginDrag(chip, mouse.x, mouse.y);
                                    } else if (dragStarted) {
                                        widgetReorder.updateDrag(chip, mouse.x, mouse.y);
                                    }
                                }
                                onReleased: function(mouse) {
                                    cursorShape = chip.draggable ? Qt.OpenHandCursor : Qt.ArrowCursor;
                                    if (dragStarted) {
                                        widgetReorder.finishDrag();
                                    } else {
                                        if (chip.fromSelection)
                                            widgetReorder.removeItem(chip.selectedIndex);
                                        else if (!chip.paletteDisabled)
                                            widgetReorder.addItem(chip.widgetId, selectedModel.count);
                                    }
                                    dragStarted = false;
                                }
                                onCanceled: {
                                    cursorShape = chip.draggable ? Qt.OpenHandCursor : Qt.ArrowCursor;
                                    dragStarted = false;
                                    widgetReorder.clearDrag();
                                }
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }

                            }

                            Behavior on border.color {
                                ColorAnimation {
                                    duration: 150
                                }

                            }

                        }

                    }

                }

            }

        }

    }

}
