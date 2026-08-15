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
import qs.features.settings
import qs.features.settings.content
import qs.services

Item {
    SwipeView {
        id: swipeView

        anchors.fill: parent
        currentIndex: SettingsControl.settingsLocation
        interactive: false
        orientation: Qt.Vertical

        Loader {
            active: swipeView.currentIndex === 0

            sourceComponent: DesktopPage {
            }

        }

        Loader {
            active: swipeView.currentIndex === 1

            sourceComponent: BarPage {
            }

        }

        Loader {
            active: swipeView.currentIndex === 2

            sourceComponent: ThemingPage {
            }

        }

        Loader {
            active: swipeView.currentIndex === 3

            sourceComponent: NotificationsPage {
            }

        }

        Loader {
            active: swipeView.currentIndex === 4

            sourceComponent: LockscreenPage {
            }

        }

        Loader {
            active: swipeView.currentIndex === 5

            sourceComponent: MiscPage {
            }

        }

        Loader {
            active: swipeView.currentIndex === 6

            sourceComponent: ComponentsPage {
            }

        }

        Loader {
            active: swipeView.currentIndex === 7

            sourceComponent: AboutPage {
            }

        }

    }

}
