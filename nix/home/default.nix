# Feature-Flagged Declarative Home Manager Module for Savior Dotfiles
# Hybrid theming: declarative config as the baseline, with Matugen-owned config
# directories seeded as writable copies so live colour regeneration works on NixOS.
{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.programs.saviorDotfiles;
  jsonFormat = pkgs.formats.json { };

  saviorThemesAndIcons = pkgs.savior-themes-and-icons or (pkgs.callPackage ../pkgs/themes-and-icons.nix { });
  saviorShell = pkgs.savior-shell or (pkgs.callPackage ../pkgs/savior-shell.nix { });

  # Import modular package groups from nix/pkgs/deps/
  coreDeps = import ../pkgs/deps/core.nix { inherit pkgs; };
  toolsDeps = import ../pkgs/deps/tools.nix { inherit pkgs; };
  mediaDeps = import ../pkgs/deps/media.nix { inherit pkgs; };
  ocrDeps = import ../pkgs/deps/ocr.nix { inherit pkgs; };
  userAppsDeps = import ../pkgs/deps/user-apps.nix { inherit pkgs lib; };
  shellDeps = import ../pkgs/deps/shell.nix { inherit pkgs; };
  wmHyprDeps = import ../pkgs/deps/wm-hyprland.nix { inherit pkgs inputs; };
  wmAwesomeDeps = import ../pkgs/deps/wm-awesome.nix { inherit pkgs; };

  # Config directories that Matugen rewrites at runtime. When Matugen is enabled
  # these are seeded as writable copies (activation) instead of store symlinks.
  matugenDirs = [ "kitty" "hypr" "wezterm" "cava" "qt5ct" "qt6ct" "zed" ];

  seedDirCalls = lib.concatMapStringsSep "\n"
    (name: ''seed_dir ${../../config/${name}} "$HOME/.config/${name}" preserve'')
    matugenDirs;

  # Quickshell settings.json seed: user-provided declaration wins over the repo default.
  quickshellSettingsSeed = if cfg.settings != { }
    then jsonFormat.generate "settings.json" cfg.settings
    else ../../config/quickshell/settings/settings.json;
in {
  # Backward compatibility option aliases
  imports = [
    (lib.mkRenamedOptionModule
      [ "programs" "saviorDotfiles" "enableMediaTools" ]
      [ "programs" "saviorDotfiles" "media" "enable" ])
    (lib.mkRenamedOptionModule
      [ "programs" "saviorDotfiles" "enableOCR" ]
      [ "programs" "saviorDotfiles" "ocr" "enable" ])
    (lib.mkRenamedOptionModule
      [ "programs" "saviorDotfiles" "enableUserApps" ]
      [ "programs" "saviorDotfiles" "userApps" "enable" ])
  ]
  # Official Vicinae module; only imported when the input is provided
  ++ lib.optionals (inputs ? vicinae) [ inputs.vicinae.homeManagerModules.default ];

  options.programs.saviorDotfiles = {
    enable = lib.mkEnableOption "Savior dotfiles (AwesomeWM/Hyprland/Quickshell)";

    wm.hyprland.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Hyprland integration and Wayland utilities";
    };

    wm.awesome.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable AwesomeWM integration and X11 utilities";
    };

    quickshell.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Quickshell Desktop Shell";
    };

    matugen.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Matugen dynamic theming engine and writable colour seeds";
    };

    media.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable audio & visualizer tools (cava, mpd, ncmpcpp, playerctl)";
    };

    ocr.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable OCR tooling";
    };

    userApps.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable recommended user applications (vscode, obsidian, brave, zed, thunar, kitty, wezterm, rofi, neovim)";
    };

    settings = lib.mkOption {
      type = jsonFormat.type;
      default = { };
      description = "Optional declarative configuration for quickshell/settings.json";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      home.packages = [ saviorShell ]
    ++ coreDeps
    ++ toolsDeps
    ++ shellDeps
    ++ lib.optionals (cfg.wm.hyprland.enable || cfg.wm.awesome.enable) [ pkgs.xwayland ]
    ++ lib.optionals cfg.wm.hyprland.enable wmHyprDeps
    ++ lib.optionals cfg.wm.awesome.enable wmAwesomeDeps
    ++ lib.optionals cfg.media.enable mediaDeps
    ++ lib.optionals cfg.ocr.enable ocrDeps
    ++ lib.optionals cfg.userApps.enable userAppsDeps;

    fonts.fontconfig.enable = true;

    # Activate GTK themes and icons
    gtk = {
      enable = true;
      theme = {
        name = "Colloid-Dark";
        package = saviorThemesAndIcons;
      };
      iconTheme = {
        name = "WhiteSur-dark";
        package = saviorThemesAndIcons;
      };
    };

    # Link config directories into ~/.config. The Matugen-owned dirs are only
    # linked declaratively when Matugen is disabled; when enabled they are seeded
    # as writable copies by home.activation.seedWritableConfigs below.
    xdg.configFile = {
      "awesome".source = ../../config/awesome;
      "quickshell/shell.qml".source = ../../config/quickshell/shell.qml;
      "quickshell/assets".source = ../../config/quickshell/assets;
      "quickshell/core".source = ../../config/quickshell/core;
      "quickshell/features".source = ../../config/quickshell/features;
      "quickshell/services".source = ../../config/quickshell/services;
      "quickshell/lib".source = ../../config/quickshell/lib;
      "matugen".source = ../../config/matugen;
      "btop".source = ../../config/btop;
      "dunst".source = ../../config/dunst;
      "fastfetch".source = ../../config/fastfetch;
      "herdr".source = ../../config/herdr;
      "kvantum".source = ../../config/kvantum;
      "nvim".source = ../../config/nvim;
      "obsidian".source = ../../config/obsidian;
      "picom".source = ../../config/picom;
      "ranger".source = ../../config/ranger;
      "rofi".source = ../../config/rofi;
      "vscode".source = ../../config/vscode;
    }
    // lib.optionalAttrs (!cfg.matugen.enable) (lib.genAttrs matugenDirs (name: {
      source = ../../config/${name};
    }));

    home.file = {
      "Pictures/Wallpapers".source = ../../assets/wallpapers;
      ".oh-my-zsh/custom/themes/Savior-zsh-theme".source = ../../assets/zsh/Savior-zsh-theme;
      ".zshrc".source = ../../assets/zsh/.zshrc;
    } // lib.optionalAttrs (cfg.wm.awesome.enable && inputs ? bling) {
      ".config/awesome/modules/bling".source = inputs.bling;
    } // lib.optionalAttrs (cfg.wm.awesome.enable && inputs ? layout-machi) {
      ".config/awesome/modules/layout-machi".source = inputs.layout-machi;
    };

    home.activation.seedWritableConfigs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      (
        set -euo pipefail

        seed_file() {
          local src="$1" dst="$2" mode="''${3:-replace}"
          mkdir -p "$(dirname "$dst")"
          if [ "$mode" = "preserve" ] && [ -e "$dst" ] && [ ! -L "$dst" ]; then
            return 0
          fi
          local tmp="$dst.tmp.$$"
          rm -f "$tmp"
          cp -f "$src" "$tmp"
          mv -f "$tmp" "$dst"
        }

        seed_dir() {
          local src="$1" dst="$2" mode="''${3:-preserve}"
          if [ "$mode" = "preserve" ] && [ -d "$dst" ] && [ ! -L "$dst" ]; then
            return 0
          fi
          local tmp="$dst.tmp.$$"
          rm -rf "$tmp"
          mkdir -p "$(dirname "$tmp")"
          cp -r "$src" "$tmp"
          rm -rf "$dst"
          mv "$tmp" "$dst"
        }

        ${lib.optionalString cfg.quickshell.enable ''
        # Quickshell settings persistence (writable; preserve user changes)
        seed_file ${quickshellSettingsSeed} "$HOME/.config/quickshell/settings/settings.json" preserve
        ''}

        ${lib.optionalString (cfg.quickshell.enable || cfg.matugen.enable) ''
        # Quickshell palette (target of matugen's quickshell template); seeded whenever
        # either Quickshell reads it or Matugen writes it.
        seed_file ${../../config/quickshell/settings/colours.json} "$HOME/.config/quickshell/settings/colours.json" preserve
        ''}

        ${lib.optionalString cfg.matugen.enable ''
        # Matugen-owned config dirs (writable copies so live regeneration works)
        ${seedDirCalls}

        # GTK colour targets (GTK dirs are managed by the HM gtk module)
        seed_file ${../../config/gtk-3.0/colors.css} "$HOME/.config/gtk-3.0/colors.css" preserve
        seed_file ${../../config/gtk-3.0/gtk.css} "$HOME/.config/gtk-3.0/gtk.css" replace
        seed_file ${../../config/gtk-4.0/colors.css} "$HOME/.config/gtk-4.0/colors.css" preserve

        # Configure adw-gtk3 GTK4 symlinks & Matugen integration
        ADW_LOCAL="$HOME/.local/share/themes/adw-gtk3/gtk-4.0"
        if [ -d "$ADW_LOCAL" ]; then
          ln -sf "$HOME/.config/gtk-4.0/colors.css" "$ADW_LOCAL/colors.css"
          for css in "$ADW_LOCAL/gtk.css" "$ADW_LOCAL/gtk-dark.css"; do
            if [ -f "$css" ] && ! grep -q 'colors.css' "$css"; then
              echo '@import url("colors.css");' >> "$css"
            fi
          done
          ln -sf "$ADW_LOCAL/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"
          ln -sf "$ADW_LOCAL/gtk-dark.css" "$HOME/.config/gtk-4.0/gtk-dark.css"
          ln -sf "$ADW_LOCAL/assets" "$HOME/.config/gtk-4.0/assets"
          ln -sf "$ADW_LOCAL/libadwaita.css" "$HOME/.config/gtk-4.0/libadwaita.css"
          ln -sf "$ADW_LOCAL/libadwaita-tweaks.css" "$HOME/.config/gtk-4.0/libadwaita-tweaks.css"
        else
          seed_file ${../../config/gtk-4.0/gtk.css} "$HOME/.config/gtk-4.0/gtk.css" replace
        fi
        ''}
      ) || { echo "seedWritableConfigs failed" >&2; exit 1; }
    '';

    # Systemd User Service for Quickshell
    systemd.user.services.quickshell = lib.mkIf cfg.quickshell.enable {
      Unit = {
        Description = "Quickshell Savior Desktop Shell";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${saviorShell}/bin/savior-shell";
        Restart = "on-failure";
        RestartSec = "2s";
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };
    })
    (lib.optionalAttrs (inputs ? vicinae) {
      # Vicinae launcher ref: https://docs.vicinae.com/nixos
      programs.vicinae = lib.mkIf (cfg.enable && cfg.userApps.enable) {
        enable = true;
        package = pkgs.vicinae;
        systemd = {
          enable = true;
          autoStart = true;
          environment = {
            USE_LAYER_SHELL = 1;
          };
        };
        settings = {
          consider_preedit = false;
          font.normal = {
            family = "SF Pro Display";
            size = 10.5;
          };
          theme.dark = {
            name = "vicinae-dark";
            icon_theme = "Mkos-Big-Sur";
          };
          launcher_window.opacity = 0.9;
          providers = {
            "@thomaslombart/store.raycast.github".preferences = {
              includeTeamReviewRequests = false;
              isOpenInBrowser = true;
              repositoryCloneProtocol = "ssh";
            };
            applications.preferences.paths = [
              "~/.local/share/applications"
              "/usr/share/applications"
            ];
            clipboard.preferences.monitoring = true;
          };
        };
      };
    })
  ];
}
