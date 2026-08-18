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
    panelHeight: 880

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
                    spacing: Styling.spacing.xxxl

                    GithubContribCalendar {
                        Layout.fillWidth: true
                        Layout.leftMargin: 20
                        Layout.rightMargin: 20
                        Layout.topMargin: 20
                    }

                    Toggles {
                    }

                    MusicCard {
                        cardHeight: 96
                        cardColor: Qt.alpha(Colours.palette.surface, 0.85)
                        borderColor: Qt.alpha(Colours.palette.outline, 0.25)
                        Layout.fillWidth: true
                        Layout.leftMargin: 20
                        Layout.rightMargin: 20
                    }

                    Sliders {
                    }

                    SystemStats {
                    }

                    Footer {
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
