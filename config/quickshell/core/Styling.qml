import QtQuick
import Quickshell
pragma Singleton

Singleton {
    id: root

    // Tipografía — deriva de la distribución real (10–28), +1 tier "display" para casos como el reloj del lockscreen
    readonly property QtObject
    fontSize: QtObject {
        property int xs: 10
        property int sm: 11
        property int label: 12
        property int body: 13
        property int bodyLarge: 14
        property int md: 15
        property int lg: 16
        property int title: 18
        property int headline: 20
        property int xl: 22
        property int xxl: 24
        property int display: 28
        property int hero: 104 // reloj de lockscreen — caso display hero
    }

    // Radios — 1000 funciona como full/pill en el diseño
    readonly property QtObject
    radius: QtObject {
        property int xs: 3
        property int sm: 8
        property int md: 9
        property int lg: 12
        property int xl: 13
        property int xxl: 18
        property int round: 100
        property int full: 1000
    }

    // Spacing — escala base 2/4/6/8/10/12/16/24
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
