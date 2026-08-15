import QtQuick
import Quickshell
pragma Singleton

Singleton {
    id: root

    readonly property var standard: [0.2, 0, 0, 1, 1, 1]
    readonly property var bounce: [0.2, 0.4, 0.4, 0, 1, 1.2, 1.3, 1]
}
