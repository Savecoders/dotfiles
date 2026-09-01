import QtQuick
import QtQuick.Layouts
import qs.core
import qs.features
import qs.features.common
import qs.features.settings.content.generics
import qs.services

AnchoredPopup {
    id: root

    required property bool isRecordingOpen

    isOpen: isRecordingOpen
    anchorX: IPCLoader.recordingX
    anchorY: IPCLoader.recordingY
    anchorWidth: IPCLoader.recordingWidth
    anchorHeight: IPCLoader.recordingHeight
    cardWidth: 320
    onDismissed: IPCLoader.isRecordingOpen = false

    cardContent: Component {
        ColumnLayout {
            id: contentCol

            spacing: Styling.spacing.lg

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Styling.spacing.xs

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Styling.spacing.md

                    // Recording dot (decorative 10x10 circular dot with pulse animation)
                    StyledRect {
                        width: 10
                        height: 10
                        radius: 5
                        useDefaultRadius: false
                        color: Recorder.isRecordingRunning ? Colours.palette.error : Colours.palette.on_surface_variant
                        border.width: 0
                        Layout.alignment: Qt.AlignVCenter

                        SequentialAnimation on opacity {
                            running: Recorder.isRecordingRunning && !Recorder.isPaused
                            loops: Animation.Infinite

                            NumberAnimation {
                                to: 0.3
                                duration: 800
                                easing.type: Easing.InOutQuad
                            }

                            NumberAnimation {
                                to: 1
                                duration: 800
                                easing.type: Easing.InOutQuad
                            }

                        }

                    }

                    Text {
                        text: Recorder.isRecordingRunning ? (Recorder.isPaused ? "Recording Paused" : "Recording") : "Screen Recorder"
                        font.family: Config.settings.font
                        font.pixelSize: Styling.fontSize.lg
                        font.weight: Font.Bold
                        color: Colours.palette.on_surface
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    // Duration on Far Right
                    Text {
                        text: Recorder.fullTime
                        font.family: Config.settings.font
                        font.pixelSize: Styling.fontSize.title
                        font.weight: Font.Bold
                        color: Recorder.isRecordingRunning ? Colours.palette.error : Colours.palette.on_surface
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    }

                }

                Text {
                    visible: Recorder.isRecordingRunning && Recorder.outputFile !== ""
                    Layout.fillWidth: true
                    text: Recorder.outputFile
                    font.family: Config.settings.font
                    font.pixelSize: Styling.fontSize.body
                    color: Qt.alpha(Colours.palette.on_surface_variant, 0.75)
                    elide: Text.ElideMiddle
                }

            }

            // FPS Selector
            RowLayout {
                Layout.fillWidth: true
                spacing: Styling.spacing.md

                Text {
                    text: "FPS"
                    font.family: Config.settings.font
                    font.pixelSize: Styling.fontSize.md
                    font.weight: Font.Normal
                    color: Colours.palette.on_surface_variant
                    Layout.preferredWidth: 32
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Styling.spacing.sm

                    Repeater {
                        model: [30, 60, 120]

                        StyledRect {
                            id: fpsPill

                            property int fpsVal: modelData
                            property bool isSelected: Recorder.fps === fpsVal
                            property bool hovered: false

                            variant: "internalbg"
                            useDefaultRadius: true
                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            color: hovered ? Colours.palette.surface_container_high : Colours.palette.surface_container_low
                            border.color: isSelected ? Colours.palette.primary : (hovered ? Colours.palette.outline : Qt.alpha(Colours.palette.outline, 0.2))
                            border.width: isSelected ? 2 : 1

                            Text {
                                anchors.centerIn: parent
                                text: String(fpsPill.fpsVal)
                                font.family: Config.settings.font
                                font.pixelSize: Styling.fontSize.md
                                font.weight: fpsPill.isSelected ? Font.Bold : Font.Normal
                                color: fpsPill.isSelected ? Colours.palette.primary : Colours.palette.on_surface
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: fpsPill.hovered = true
                                onExited: fpsPill.hovered = false
                                onClicked: {
                                    Recorder.fps = fpsPill.fpsVal;
                                    Config.updateKey("recorder.fps", fpsPill.fpsVal);
                                }
                            }

                        }

                    }

                }

            }

            // Audio Switches using reusable SliceToggle components
            SliceToggle {
                icon: "volume_up"
                text: "System audio"
                isToggled: Recorder.recordSystemAudio
                onToggled: (st) => {
                    Recorder.recordSystemAudio = st;
                    Config.updateKey("recorder.recordSystemAudio", st);
                }
            }

            SliceToggle {
                icon: "mic"
                text: "Microphone"
                isToggled: Recorder.recordMicrophone
                onToggled: (st) => {
                    Recorder.recordMicrophone = st;
                    Config.updateKey("recorder.recordMicrophone", st);
                }
            }

            // Action Buttons Row (Pause/Resume + Finish/Start)
            RowLayout {
                Layout.fillWidth: true
                spacing: Styling.spacing.md

                MButton {
                    visible: Recorder.isRecordingRunning
                    icon: Recorder.isPaused ? "play_arrow" : "pause"
                    text: Recorder.isPaused ? "Resume" : "Pause"
                    btnVariant: "secondary"
                    onClicked: {
                        if (Recorder.isPaused)
                            Recorder.resumeRecording();
                        else
                            Recorder.pauseRecording();
                    }
                }

                MButton {
                    icon: Recorder.isRecordingRunning ? "stop" : "fiber_manual_record"
                    text: Recorder.isRecordingRunning ? "Finish" : "Start Recording"
                    btnVariant: Recorder.isRecordingRunning ? "danger" : "primary"
                    onClicked: Recorder.toggleRecording()
                }

            }

            // Open Recordings Folder Button
            MButton {
                icon: "folder"
                text: "Open recordings folder"
                btnVariant: "secondary"
                Layout.preferredHeight: 36
                onClicked: Recorder.openRecordingsFolder()
            }

        }

    }

}
