import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.core
import qs.features.dashboard.sliders
import qs.services

ColumnLayout {
    id: root

    Layout.fillWidth: true
    Layout.leftMargin: 20
    Layout.rightMargin: 20
    spacing: Styling.spacing.xxxl

    MSlider {
        Layout.fillWidth: true
        title: "Volume"
        iconCode: Audio.muted ? "volume_off" : (Audio.volume > 0.5 ? "volume_up" : (Audio.volume > 0.05 ? "volume_down" : "volume_mute"))
        from: 0
        to: 1
        value: Audio.volume ?? 0
        isEnabled: !Audio.muted
        onMoved: Audio.setVolume(value)
    }

    MSlider {
        Layout.fillWidth: true
        title: "Brightness"
        iconCode: "brightness_medium"
        from: 1
        to: 100
        value: Brightness.brightnessPercent ?? 50
        isEnabled: true
        onMoved: Brightness.setBrightnessPercent(value)
    }

}
