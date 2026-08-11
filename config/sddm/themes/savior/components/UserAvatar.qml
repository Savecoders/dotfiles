import QtQuick

Rectangle {
    id: root

    property string avatarPath: ""

    width: 44
    height: 44
    radius: 22
    color: config.primary_container ? config.primary_container : "#005141"
    border.color: config.primary ? config.primary : "#87d6bd"
    border.width: 2

    Image {
        id: avatarImg

        anchors.fill: parent
        anchors.margins: 2
        fillMode: Image.PreserveAspectCrop
        source: root.avatarPath !== "" ? root.avatarPath : Qt.resolvedUrl("../icon.png")
        onStatusChanged: {
            if (status === Image.Error || status === Image.Null)
                source = Qt.resolvedUrl("../icon.png");

        }
    }

}
