import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.core
import qs.features
import qs.features.common
import qs.features.dashboard
import qs.features.dashboard.sliders
import qs.services

Item {
    id: root

    Layout.fillWidth: true
    Layout.leftMargin: 20
    Layout.rightMargin: 20
    Layout.preferredHeight: contentColumn.implicitHeight
    implicitHeight: contentColumn.implicitHeight

    ColumnLayout {
        id: contentColumn

        anchors.fill: parent
        spacing: 10

        MSlider {
            Layout.fillWidth: true
            iconCode: Audio.muted ? "volume_off" : "volume_up"
            from: 0
            to: 1
            value: Audio.volume
            isEnabled: !Audio.muted
            onMoved: Audio.setVolume(value)
        }

        MSlider {
            Layout.fillWidth: true
            iconCode: "brightness_medium"
            from: 0
            to: 100
            value: Brightness.brightnessPercent
            onMoved: Brightness.setBrightnessPercent(value)
        }

    }

}
