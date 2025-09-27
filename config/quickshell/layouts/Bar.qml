// Bar.qml
import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root
    property string time

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            color: "transparent"
            screen: modelData

            anchors {
                top: true
                left: true
                right: false
                bottom: true
            }

            implicitHeight: 24
            implicitWidth: 32

            Rectangle {
                anchors.fill: parent
                color: "white"
                radius: 8
                // bottomLeftRadius: 12
                // bottomRightRadius: 12
                opacity: 0.8

                Text {
                    anchors.centerIn: parent
                    text: root.time
                }
            }
        }
    }

    Process {
        id: dateProc
        command: ["date"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.time = this.text
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: dateProc.running = true
    }
}
