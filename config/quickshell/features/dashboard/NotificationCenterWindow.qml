import QtQuick
import QtQuick.Controls
import qs.core
import qs.features.common
import qs.features.dashboard

SlideOverWindow {
    id: root

    required property bool isNotificationsOpen

    isOpen: isNotificationsOpen
    panelWidth: 515
    panelHeight: 960

    contentComponent: Component {
        NotificationLog {
            anchors.fill: parent
        }

    }

}
