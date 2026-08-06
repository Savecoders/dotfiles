# Recommended user applications (enabled via enableUserApps option)
# vicinae and herdr are only added when available in nixpkgs (they are AUR/upstream on Arch).
{ pkgs, lib }:

with pkgs; [
  kitty
  wezterm
  rofi-wayland
  neovim
  zed-editor
  vscode
  obsidian
  brave
  xfce.thunar
  btop
  fastfetch
  eza
  bat
  fzf
] ++ lib.optionals (pkgs ? vicinae) [ pkgs.vicinae ]
  ++ lib.optionals (pkgs ? herdr) [ pkgs.herdr ]
