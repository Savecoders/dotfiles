import QtQuick
import Quickshell
pragma Singleton

Singleton {
    id: root

    readonly property int desktopGap: 4
    readonly property QtObject
    fontSize: QtObject {
        property int caption: 10
        property int xs: 8
        property int sm: 12
        property int body: 13
        property int bodyLarge: 14
        property int md: 14
        property int label: 14
        property int lg: 16
        property int title: 18
        property int headline: 20
        property int xl: 20
        property int xxl: 24
        property int display: 32
        property int hero: 104 //hero lookscreen
    }

    readonly property QtObject
    radius: QtObject {
        property int xs: 4
        property int sm: 8
        property int md: 10
        property int lg: 12
        property int xl: 14
        property int xxl: 18
        property int round: 100
        property int full: 1000
    }

    readonly property QtObject
    spacing: QtObject {
        property int none: 0
        property int xs: 2
        property int sm: 4
        property int md: 6
        property int lg: 8
        property int xl: 10
        property int xxl: 12
        property int xxxl: 16
        property int section: 24
    }

}
