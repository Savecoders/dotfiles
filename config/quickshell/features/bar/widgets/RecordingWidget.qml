import QtQuick
import qs.core
import qs.features
import qs.services

BarIconButton {
    id: root

    collapsible: false
    active: Recorder.isRecordingRunning
    iconGlyph: "screen_record"
    tooltipText: Recorder.isRecordingRunning ? "Recording in progress (Click for controls)" : "Screen Recorder"
    activeColor: Colours.palette.error_container
    activeContentColor: Colours.palette.primary
    onActivated: IPCLoader.toggleRecordingAt(root)
}
