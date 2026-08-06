# Unified buildEnv package: Quickshell + custom fonts + savior-shell launcher.
# Everything else (matugen, rofi, grim, playerctl, ...) lives in home.packages.
{ pkgs, inputs, savior-fonts ? pkgs.callPackage ./fonts.nix {} }:

let
  quickshellPkg = inputs.quickshell.packages.${pkgs.system}.default;

  # Shell launcher wrapper
  launcher = pkgs.writeShellScriptBin "savior-shell" ''
    export PATH="${quickshellPkg}/bin:${savior-fonts}/bin:$PATH"

    # Quickshell QML modules are installed to the Qt6 QML dir
    export QML2_IMPORT_PATH="${quickshellPkg}/lib/qt-6/qml:''${QML2_IMPORT_PATH:-}"
    export QML_IMPORT_PATH="$QML2_IMPORT_PATH"

    # Prepend font dir to XDG_DATA_DIRS instead of clobbering FONTCONFIG_PATH
    export XDG_DATA_DIRS="${savior-fonts}/share:''${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"

    exec ${quickshellPkg}/bin/quickshell -p "$HOME/.config/quickshell/shell.qml" "$@"
  '';
in pkgs.buildEnv {
  name = "savior-shell";
  paths = [ quickshellPkg savior-fonts launcher ];
  meta = with pkgs.lib; {
    description = "Savior Quickshell environment and launcher";
    mainProgram = "savior-shell";
  };
}
