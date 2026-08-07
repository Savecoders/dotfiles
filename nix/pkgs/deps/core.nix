# Core Qt6, Wayland & Graphics libraries required by Quickshell & Compositors.
# (quickshell itself is bundled into savior-shell, so it is not listed here.)
{ pkgs }:

with pkgs; [
  qt6.qtbase
  qt6.qtsvg
  qt6.qtdeclarative
  qt6.qtwayland
  qt5.qtwayland
  qt5.qtgraphicaleffects
  qt5.qtquickcontrols2
  libsForQt5.qt5ct
  qt6Packages.qt6ct
  libsForQt5.qtstyleplugin-kvantum
]
