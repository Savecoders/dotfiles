import QtQuick
import Quickshell
import Quickshell.Io
import qs.core
pragma Singleton

Singleton {
    id: root

    readonly property var background: _slot("../features/desktop/Desktop.qml")
    readonly property var powermenu: _slot("../features/powermenu/Powermenu.qml")
    readonly property var overlays: _slot("../features/overlays/Overlays.qml")

    function _slot(defaultPath) {
        return slotComponent.createObject(root, {
            "source": Qt.resolvedUrl(defaultPath)
        });
    }

    Component {
        id: slotComponent

        QtObject {
            property url source
            property bool overridden: false
            property bool disabled: false
            readonly property bool active: !disabled

            function override(newSource) {
                source = newSource;
                overridden = true;
            }

            function disable() {
                disabled = true;
            }

        }

    }

}
