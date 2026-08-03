import QtQuick
import qs.services

Text {
    property bool isVertical: false

    text: {
        if (isVertical)
            return Time.hour + "\n" + Time.minute;
        else
            return Time.date + "  " + Time.time;
    }
}
