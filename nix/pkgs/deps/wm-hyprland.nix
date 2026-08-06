# Hyprland Wayland compositor stack (gated by wm.hyprland.enable)
# hyprland comes from the pinned flake input so system (programs.hyprland)
# and home profile versions never diverge. xwayland is installed once in
# home.packages, gated on either WM being enabled.
{ pkgs, inputs }:

with pkgs; [
  inputs.hyprland.packages.${pkgs.system}.hyprland
  hyprpaper
  hyprlock
  hypridle
  hyprsunset
  gammastep
]
