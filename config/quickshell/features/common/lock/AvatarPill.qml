import QtQuick
import qs.core

StyledRect {
    id: root

    property Theme theme: themeDefault
    property string avatarPath: ""
    property url fallbackSource: ""

    useDefaultRadius: false
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
        anchors.margins: Styling.spacing.xs
        sourceSize: Qt.size(width > 0 ? width : 40, height > 0 ? height : 40)
        fillMode: Image.PreserveAspectCrop
        source: root.avatarPath !== "" ? root.avatarPath : root.fallbackSource
        onStatusChanged: {
            if ((status === Image.Error || status === Image.Null) && source !== root.fallbackSource)
                source = root.fallbackSource;

        }
    }

}
