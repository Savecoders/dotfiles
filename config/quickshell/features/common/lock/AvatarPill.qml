import QtQuick

Rectangle {
    id: root

    property Theme theme: themeDefault
    property string avatarPath: ""
    property url fallbackSource: ""

    width: 44
    height: 44
    radius: width / 2
    color: root.theme.primaryContainer
    border.color: root.theme.primary
    border.width: 2

    Theme {
        id: themeDefault
    }

    Image {
        id: avatarImg

        anchors.fill: parent
        anchors.margins: 2
        fillMode: Image.PreserveAspectCrop
        source: root.avatarPath !== "" ? root.avatarPath : root.fallbackSource
        onStatusChanged: {
            if ((status === Image.Error || status === Image.Null) && source !== root.fallbackSource)
                source = root.fallbackSource;

        }
    }

}
