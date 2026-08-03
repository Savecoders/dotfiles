import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.core
import qs.features
import qs.features.common

Rectangle {
    id: root

    property var bar

    visible: SystemTray.items.values.length > 0
    color: "transparent"
    implicitWidth: (bar && bar.isVertical) ? 32 : Math.max(32, SystemTray.items.values.length * 24 + Math.max(0, SystemTray.items.values.length - 1) * 8)
    implicitHeight: (bar && bar.isVertical) ? Math.max(32, SystemTray.items.values.length * 24 + Math.max(0, SystemTray.items.values.length - 1) * 8) : 32
    width: implicitWidth
    height: implicitHeight

    GridLayout {
        id: layout

        anchors.centerIn: parent
        columns: (bar && bar.isVertical) ? 1 : 20
        rows: (bar && bar.isVertical) ? 20 : 1
        columnSpacing: 8
        rowSpacing: 8

        Repeater {
            model: SystemTray.items

            delegate: Rectangle {
                id: sysItem

                required property var modelData

                Layout.alignment: Qt.AlignCenter
                height: 24
                width: 24
                color: "transparent"

                Loader {
                    anchors.centerIn: parent
                    active: !!(sysItem.modelData && sysItem.modelData.icon && sysItem.modelData.icon !== "")

                    sourceComponent: IconImage {
                        width: 16
                        height: 16
                        source: sysItem.modelData.icon
                    }

                }

                QsMenuAnchor {
                    id: menu

                    menu: sysItem.modelData.menu
                    anchor.item: sysItem
                    anchor.edges: Edges.Bottom | Edges.Left
                    anchor.gravity: Edges.Bottom | Edges.Left
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: (event) => {
                        if (event.button === Qt.LeftButton)
                            modelData.activate();
                        else if (modelData.hasMenu)
                            menu.open();
                    }
                }

            }

        }

    }

}
