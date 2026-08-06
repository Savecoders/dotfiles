# Derivation packaging custom bundled fonts from assets/fonts
{ pkgs }:

pkgs.stdenvNoCC.mkDerivation {
  pname = "savior-fonts";
  version = "1.0.0";

  src = ../../assets/fonts;

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype $out/share/fonts/opentype
    find . -type f -name "*.ttf" -exec cp {} $out/share/fonts/truetype/ \;
    find . -type f -name "*.otf" -exec cp {} $out/share/fonts/opentype/ \;

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Custom font collection for Savior dotfiles (DankMono, SF Pro, FontAwesome, icommon)";
    platforms = platforms.all;
  };
}
