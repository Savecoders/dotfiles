pragma Singleton
import qs.core
import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Singleton {
    id: root

    property string previousSinkName: ""
    property string previousSourceName: ""
    readonly property var nodes: Pipewire.nodes.values.reduce((acc, node) => {
        if (!node.isStream) {
            if (node.isSink)
                acc.sinks.push(node);
            else if (node.audio)
                acc.sources.push(node);
        }
        return acc;
    }, {
        "sources": [],
        "sinks": []
    })
    readonly property var sinks: nodes.sinks
    readonly property var sources: nodes.sources
    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource
    readonly property bool muted: !!(sink && sink.audio && sink.audio.muted)
    readonly property real volume: (sink && sink.audio) ? sink.audio.volume : 0
    readonly property bool sourceMuted: !!(source && source.audio && source.audio.muted)
    readonly property real sourceVolume: (source && source.audio) ? source.audio.volume : 0

    function setVolume(newVolume) {
        if (sink && sink.ready && sink.audio) {
            sink.audio.muted = false;
            sink.audio.volume = Math.max(0, Math.min(1, newVolume));
        }
    }

    function incrementVolume(amount) {
        setVolume(volume + (amount || Config.services.audioIncrement));
    }

    function decrementVolume(amount) {
        setVolume(volume - (amount || Config.services.audioIncrement));
    }

    function setSourceVolume(newVolume) {
        if (source && source.ready && source.audio) {
            source.audio.muted = false;
            source.audio.volume = Math.max(0, Math.min(1, newVolume));
        }
    }

    function incrementSourceVolume(amount) {
        setSourceVolume(sourceVolume + (amount || Config.services.audioIncrement));
    }

    function decrementSourceVolume(amount) {
        setSourceVolume(sourceVolume - (amount || Config.services.audioIncrement));
    }

    function setAudioSink(newSink) {
        Pipewire.preferredDefaultAudioSink = newSink;
    }

    function setAudioSource(newSource) {
        Pipewire.preferredDefaultAudioSource = newSource;
    }

    onSinkChanged: {
        if (!sink || !sink.ready)
            return ;

        const newSinkName = sink.description || sink.name || qsTr("Unknown Device");
        if (previousSinkName && previousSinkName !== newSinkName)
            Quickshell.execDetached(["notify-send", "Audio output changed", `Now using: ${newSinkName}`]);

        previousSinkName = newSinkName;
    }
    onSourceChanged: {
        if (!source || !source.ready)
            return ;

        const newSourceName = source.description || source.name || qsTr("Unknown Device");
        if (previousSourceName && previousSourceName !== newSourceName)
            Quickshell.execDetached(["notify-send", "Audio input changed", `Now using: ${newSourceName}`]);

        previousSourceName = newSourceName;
    }
    Component.onCompleted: {
        previousSinkName = (sink && (sink.description || sink.name)) ? (sink.description || sink.name) : qsTr("Unknown Device");
        previousSourceName = (source && (source.description || source.name)) ? (source.description || source.name) : qsTr("Unknown Device");
    }

    PwObjectTracker {
        objects: [sink, source]
    }

}
