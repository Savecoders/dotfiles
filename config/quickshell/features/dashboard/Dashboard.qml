import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.core
import qs.features.common
import qs.features.dashboard

SlideOverWindow {
    id: root

    required property bool isDashboardOpen

    isOpen: isDashboardOpen
    panelWidth: 515
    panelHeight: 800

    contentComponent: Component {
        Item {
            anchors.fill: parent

            MouseArea {
                property int startX

                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                onPressed: (event) => {
                    startX = event.x;
                }
                onPositionChanged: (event) => {
                    let difference = startX - event.x;
                    if ((root._isLeft && difference > 30) || (!root._isLeft && difference < -30))
                        IPCLoader.isDashboardOpen = false;

                }
            }

            ScrollView {
                id: scrollView

                anchors.fill: parent
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                ColumnLayout {
                    id: contentColumn

                    width: scrollView.width
                    spacing: 16

                    GithubContribCalendar {
                        Layout.fillWidth: true
                        Layout.leftMargin: 20
                        Layout.rightMargin: 20
                        Layout.topMargin: 20
                    }

                    Toggles {
                    }

                    Music {
                    }

                    Sliders {
                    }

                    SystemStats {
                    }

                    Bottom {
                        Layout.fillWidth: true
                        Layout.leftMargin: 20
                        Layout.rightMargin: 20
                        Layout.bottomMargin: 20
                    }

                }

            }

        }

    }

}
