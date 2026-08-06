# Derivation unpacking and installing custom GTK themes and icon packs from assets/
{ pkgs }:

pkgs.stdenvNoCC.mkDerivation {
  pname = "savior-themes-and-icons";
  version = "1.0.0";

  srcs = [
    ../../assets/themes
    ../../assets/icons
  ];

  sourceRoot = ".";

  nativeBuildInputs = with pkgs; [
    tar
    unzip
    xz
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/themes $out/share/icons

    # Extract GTK themes
    if [ -d themes ]; then
      for theme_archive in themes/*.tar.xz themes/*.zip; do
        if [ -f "$theme_archive" ]; then
          case "$theme_archive" in
            *.zip) unzip -q "$theme_archive" -d $out/share/themes/ ;;
            *.tar.xz) tar -xf "$theme_archive" -C $out/share/themes/ ;;
          esac
        fi
      done
    fi

    # Extract Icon packs
    if [ -d icons ]; then
      for icon_archive in icons/*.tar.xz icons/*.zip; do
        if [ -f "$icon_archive" ]; then
          case "$icon_archive" in
            *.zip) unzip -q "$icon_archive" -d $out/share/icons/ ;;
            *.tar.xz) tar -xf "$icon_archive" -C $out/share/icons/ ;;
          esac
        fi
      done
    fi

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Custom GTK themes and icon packs for Savior dotfiles";
    platforms = platforms.all;
  };
}
