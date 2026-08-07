{ pkgs, lib }:

with pkgs; [
  kitty
  wezterm
  rofi
  neovim
  zed-editor
  vscode
  obsidian
  brave
  thunar
  btop
  fastfetch
  eza
  bat
  fzf
] ++ lib.optionals (pkgs ? herdr) [ pkgs.herdr ]
