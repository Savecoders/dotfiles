# Zsh shell and plugins required by the bundled .zshrc and oh-my-zsh theme
{ pkgs }:

with pkgs; [
  zsh
  zsh-autosuggestions
  zsh-autocomplete
  zsh-syntax-highlighting
]
