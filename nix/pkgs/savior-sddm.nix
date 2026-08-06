# Derivation packaging savior SDDM theme
{ pkgs }:

pkgs.stdenvNoCC.mkDerivation {
  pname = "savior-sddm-theme";
  version = "1.0.0";

  src = ../../config/sddm/themes/savior;

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/sddm/themes/savior
    cp -r * $out/share/sddm/themes/savior/

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Savior theme for SDDM display manager";
    platforms = platforms.all;
  };
}
