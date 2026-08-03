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

            property string background: "#111415"
            property string error: "#ffb4ab"
            property string error_container: "#93000a"
            property string inverse_on_surface: "#2e3132"
            property string inverse_primary: "#206773"
            property string inverse_surface: "#e1e3e3"
            property string on_background: "#e1e3e3"
            property string on_error: "#690005"
            property string on_error_container: "#ffdad6"
            property string on_primary: "#00363e"
            property string on_primary_container: "#000000"
            property string on_primary_fixed: "#001f24"
            property string on_primary_fixed_variant: "#004e59"
            property string on_secondary: "#1d3438"
            property string on_secondary_container: "#cbe5ea"
            property string on_secondary_fixed: "#061f23"
            property string on_secondary_fixed_variant: "#334a4f"
            property string on_surface: "#e1e3e3"
            property string on_surface_variant: "#bfc8ca"
            property string on_tertiary: "#3d2652"
            property string on_tertiary_container: "#000000"
            property string on_tertiary_fixed: "#27103b"
            property string on_tertiary_fixed_variant: "#553d6a"
            property string outline: "#899294"
            property string outline_variant: "#3f484a"
            property string primary: "#90d1de"
            property string primary_container: "#599aa7"
            property string primary_fixed: "#acedfa"
            property string primary_fixed_dim: "#90d1de"
            property string scrim: "#000000"
            property string secondary: "#b2cbd0"
            property string secondary_container: "#334a4f"
            property string secondary_fixed: "#cee7ed"
            property string secondary_fixed_dim: "#b2cbd0"
            property string shadow: "#000000"
            property string source_color: "#438591"
            property string surface: "#111415"
            property string surface_bright: "#363a3a"
            property string surface_container: "#1d2021"
            property string surface_container_high: "#272a2b"
            property string surface_container_highest: "#323536"
            property string surface_container_low: "#191c1d"
            property string surface_container_lowest: "#0b0f0f"
            property string surface_dim: "#111415"
            property string surface_tint: "#90d1de"
            property string surface_variant: "#3f484a"
            property string tertiary: "#dabbf1"
            property string tertiary_container: "#a286b8"
            property string tertiary_fixed: "#f1daff"
            property string tertiary_fixed_dim: "#dabbf1"
        }

    }

}
