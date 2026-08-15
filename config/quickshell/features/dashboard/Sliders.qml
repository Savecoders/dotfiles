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
    spacing: Styling.spacing.xl

    MSlider {
        Layout.fillWidth: true
        iconCode: Audio.muted ? "volume_off" : "volume_up"
        from: 0
        to: 1
        value: Audio.volume ?? 0
        isEnabled: !Audio.muted
        onMoved: Audio.setVolume(value)
    }

    MSlider {
        Layout.fillWidth: true
        iconCode: "brightness_medium"
        from: 0
        to: 100
        value: Brightness.brightnessPercent ?? 50
        onMoved: Brightness.setBrightnessPercent(value)
    }

}
