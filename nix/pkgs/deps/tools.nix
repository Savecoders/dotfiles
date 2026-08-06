# Desktop utilities required by widgets, scripts, and theming
{ pkgs }:

with pkgs; [
  matugen
  brightnessctl
  playerctl
  grim
  slurp
  swappy
  wf-recorder
  wl-clipboard
  cliphist
  libnotify
  upower
  acpi
  acpid
  lm_sensors
  scrot
  gpick
  inotify-tools
  xdotool
  xclip
  jq
  unzip
  tar
  curl
  gsettings-desktop-schemas
  glib.bin
  adw-gtk3
  kdePackages.polkit-kde-agent-1
]
