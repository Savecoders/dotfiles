import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property var palette: jsonColoursContent

    signal coloursChanged()

    FileView {
        id: jsonColoursSink

        path: Quickshell.shellDir + "/settings/colours.json"
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: (error) => {
            if (error == FileViewError.FileNotFound)
                writeAdapter();

        }
        onLoaded: root.coloursChanged()

        JsonAdapter {
            id: jsonColoursContent

            property string background: "#181210"
            property string blue: "#c3ccff"
            property string blue_container: "#9eaffd"
            property string dark_cyan: "#b6ddff"
            property string dark_cyan_container: "#83c3f6"
            property string error: "#ffb4ab"
            property string error_container: "#93000a"
            property string green: "#d7fda7"
            property string green_container: "#bbe08d"
            property string inverse_on_surface: "#362f2c"
            property string inverse_primary: "#8c4e35"
            property string inverse_surface: "#ede0dc"
            property string magenta: "#f4c0ff"
            property string magenta_container: "#dca1eb"
            property string on_background: "#ede0dc"
            property string on_blue: "#162a70"
            property string on_blue_container: "#092067"
            property string on_dark_cyan: "#003450"
            property string on_dark_cyan_container: "#00324e"
            property string on_error: "#690005"
            property string on_error_container: "#ffdad6"
            property string on_green: "#1f3700"
            property string on_green_container: "#2a4703"
            property string on_magenta: "#4b1a5b"
            property string on_magenta_container: "#431354"
            property string on_orange: "#512409"
            property string on_orange_container: "#55270c"
            property string on_pink: "#4c2337"
            property string on_pink_container: "#5b2f44"
            property string on_primary: "#53220c"
            property string on_primary_container: "#000000"
            property string on_primary_fixed: "#370e00"
            property string on_primary_fixed_variant: "#6f3720"
            property string on_purple: "#4b1a5b"
            property string on_purple_container: "#431354"
            property string on_red: "#5e141b"
            property string on_red_container: "#47020c"
            property string on_secondary: "#452a1f"
            property string on_secondary_container: "#ffd8ca"
            property string on_secondary_fixed: "#2c150c"
            property string on_secondary_fixed_variant: "#5e4034"
            property string on_surface: "#ede0dc"
            property string on_surface_variant: "#d8c2ba"
            property string on_teal: "#003829"
            property string on_teal_container: "#004835"
            property string on_tertiary: "#003734"
            property string on_tertiary_container: "#000000"
            property string on_tertiary_fixed: "#00201e"
            property string on_tertiary_fixed_variant: "#00504c"
            property string on_violet: "#53201d"
            property string on_violet_container: "#491916"
            property string on_yellow: "#3f2d12"
            property string on_yellow_container: "#594428"
            property string orange: "#ffd7c4"
            property string orange_container: "#fcb28d"
            property string outline: "#a08d86"
            property string outline_variant: "#53433e"
            property string pink: "#ffe8ef"
            property string pink_container: "#fec0da"
            property string primary: "#ffb599"
            property string primary_container: "#c77f62"
            property string primary_fixed: "#ffdbce"
            property string primary_fixed_dim: "#ffb599"
            property string purple: "#f4c0ff"
            property string purple_container: "#dca1eb"
            property string red: "#ffb3b3"
            property string red_container: "#f88b8d"
            property string scrim: "#000000"
            property string secondary: "#e8bdae"
            property string secondary_container: "#5e4034"
            property string secondary_fixed: "#ffdbce"
            property string secondary_fixed_dim: "#e8bdae"
            property string shadow: "#000000"
            property string source_color: "#aa674c"
            property string surface: "#181210"
            property string surface_bright: "#3f3735"
            property string surface_container: "#251e1c"
            property string surface_container_high: "#302826"
            property string surface_container_highest: "#3b3330"
            property string surface_container_low: "#211a18"
            property string surface_container_lowest: "#130d0b"
            property string surface_dim: "#181210"
            property string surface_tint: "#ffb599"
            property string surface_variant: "#53433e"
            property string teal: "#b7ffe1"
            property string teal_container: "#9be2c5"
            property string tertiary: "#88d4ce"
            property string tertiary_container: "#519d98"
            property string tertiary_fixed: "#a4f0ea"
            property string tertiary_fixed_dim: "#88d4ce"
            property string violet: "#ffc0bb"
            property string violet_container: "#eea099"
            property string yellow: "#ffffff"
            property string yellow_container: "#fdddb7"
        }

    }

}
