# Savior packages overlay for nixpkgs
inputs: final: prev: {
  savior-fonts = prev.callPackage ../pkgs/fonts.nix { };
  savior-themes-and-icons = prev.callPackage ../pkgs/themes-and-icons.nix { };
  savior-sddm = prev.callPackage ../pkgs/savior-sddm.nix { };
  savior-shell = prev.callPackage ../pkgs/savior-shell.nix {
    quickshellPkg =
      if inputs ? quickshell
      then inputs.quickshell.packages.${prev.system}.default
      else prev.quickshell;
    savior-fonts = final.savior-fonts;
  };
}
