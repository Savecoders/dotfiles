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
import qs.features.dashboard.toggles
import qs.services

Item {
    id: root

    property int fHeight: 184
    property int spacing: Styling.spacing.xl
    property int rowHeight: 87
    readonly property int availWidth: root.width > 0 ? root.width : 475
    readonly property int row1WideWidth: Math.floor((availWidth - 2 * spacing) * 0.5)
    readonly property int row1CubeWidth: Math.floor((availWidth - 2 * spacing) * 0.25)
    readonly property int row1CubeWidthLast: (availWidth - 2 * spacing) - row1WideWidth - row1CubeWidth
    readonly property int row2WideWidth: Math.floor((availWidth - spacing) * 0.5)
    readonly property int row2WideWidthLast: (availWidth - spacing) - row2WideWidth

    Layout.fillWidth: true
    Layout.leftMargin: 20
    Layout.rightMargin: 20
    Layout.preferredHeight: contentColumn.implicitHeight
    implicitHeight: contentColumn.implicitHeight

    ColumnLayout {
        id: contentColumn

        width: parent.width
        anchors.fill: parent
        spacing: root.spacing

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: root.rowHeight
            spacing: root.spacing

            Toggle {
                rWidth: root.row1WideWidth
                rHeight: root.rowHeight
                isToggled: Network.getBool()
                bigText: Network.textLabel
                smallText: {
                    if (Network.textLabel == "Disconnected")
                        return "Not connected to Wifi";
                    else if (Network.textLabel == "Network Off")
                        return "Wifi disabled";
                    else
                        return "Connected";
                }
                iconCode: Network.getIcon()
                toRun: () => {
                    return Quickshell.execDetached([`${Quickshell.shellDir}/lib/network.out`]);
                }
            }

            Toggle {
                rWidth: root.row1CubeWidth
                rHeight: root.rowHeight
                compact: true
                isToggled: Recorder.isRecordingRunning
                bigText: Recorder.isRecordingRunning ? Recorder.fullTime : "Screen Capture"
                iconCode: "screen_record"
                bgColour: Qt.alpha(Colours.palette.error_container, 0.8)
                colour: Qt.alpha(Colours.palette.on_error_container, 0.8)
                bgColourHovered: Colours.palette.error_container
                colourHovered: Colours.palette.on_error_container
                bgColourHoveredUntoggled: Qt.alpha(Colours.palette.error_container, 0.5)
                colourHoveredUntoggled: Qt.alpha(Colours.palette.on_error_container, 0.8)
                toRun: () => {
                    return Recorder.toggleRecording();
                }
            }

            Toggle {
                rWidth: root.row1CubeWidthLast
                rHeight: root.rowHeight
                compact: true
                isToggled: Notifications.popupInhibited
                bigText: Notifications.popupInhibited ? "Do Not\nDisturb" : "Disturb"
                iconCode: Notifications.popupInhibited ? "do_not_disturb_on" : "do_not_disturb_off"
                iconSize: 25
                toRun: () => {
                    return Notifications.toggleDND();
                }
            }

        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: root.rowHeight
            spacing: root.spacing

            Toggle {
                rWidth: root.row2WideWidth
                rHeight: root.rowHeight
                isToggled: Bluetooth.getBool()
                bigText: Bluetooth.textLabel
                smallText: {
                    if (Bluetooth.textLabel == "Not Connected")
                        return "No devices connected";
                    else if (Bluetooth.textLabel == "Bluetooth Off")
                        return "Wireless disabled";
                    else
                        return "Connected";
                }
                iconCode: Bluetooth.getIcon()
                toRun: () => {
                    return Bluetooth.toggle();
                }
            }

            Toggle {
                rWidth: root.row2WideWidthLast
                rHeight: root.rowHeight
                isToggled: Nightmode.isNightmodeOn
                bigText: Nightmode.isNightmodeOn ? "Nightmode On" : "Nightmode Off"
                smallText: Nightmode.isNightmodeOn ? "Warm temperature" : "Cool temperature"
                iconCode: Nightmode.isNightmodeOn ? "bedtime" : "bedtime_off"
                toRun: () => {
                    return Nightmode.toggle();
                }
            }

        }

    }

}
