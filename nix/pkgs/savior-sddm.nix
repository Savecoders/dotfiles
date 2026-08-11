# Derivation packaging savior SDDM theme
{ pkgs }:

pkgs.stdenvNoCC.mkDerivation {
  pname = "savior-sddm-theme";
  version = "1.0.0";

  src = ../../.;

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/sddm/themes/savior
    cp -r config/sddm/themes/savior/. $out/share/sddm/themes/savior/
    cp -r config/quickshell/features/common/lock/. $out/share/sddm/themes/savior/components/

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Savior theme for SDDM display manager";
    platforms = platforms.all;
  };
}
