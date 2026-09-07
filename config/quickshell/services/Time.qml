import QtQuick
import Quickshell
pragma Singleton

Singleton {
    id: root

    property bool use12h: false
    readonly property string hour: {
        let t = clock.date || clock.time;
        return use12h ? Qt.formatTime(new Date(), "hh") : Qt.formatTime(new Date(), "HH");
    }
    readonly property string minute: {
        let t = clock.date || clock.time;
        return Qt.formatTime(new Date(), "mm");
    }
    readonly property string ampm: {
        let t = clock.date || clock.time;
        return Qt.formatTime(new Date(), "AP");
    }
    readonly property string time: use12h ? `${hour}:${minute} ${ampm}` : `${hour}:${minute}`
    readonly property string date: {
        let t = clock.date || clock.time;
        return Qt.formatDate(new Date(), "ddd dd MMM");
    }
    readonly property string fullDate: {
        let t = clock.date || clock.time;
        return Qt.formatDate(new Date(), "dddd, MMMM d, yyyy");
    }

    function resync() {
        clock.enabled = false;
        clock.enabled = true;
    }

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

}
