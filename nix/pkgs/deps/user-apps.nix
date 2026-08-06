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
] ++ lib.optionals (pkgs ? herdr) [ pkgs.herdr ]
