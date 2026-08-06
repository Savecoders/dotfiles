# Hyprland Wayland compositor stack (gated by wm.hyprland.enable)
# Uses the pinned flake input when present so system (programs.hyprland) and home
# profile versions never diverge; falls back to the nixpkgs package otherwise.
# xwayland is installed once in home.packages, gated on either WM being enabled.
{ pkgs, inputs }:

with pkgs; [
  (if inputs ? hyprland
   then inputs.hyprland.packages.${pkgs.system}.hyprland
   else pkgs.hyprland)
  hyprpaper
  hyprlock
  hypridle
  hyprsunset
  gammastep
]
