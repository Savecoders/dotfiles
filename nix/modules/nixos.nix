# NixOS System Module for Savior Dotfiles
{ config, lib, pkgs, inputs, ... }:

let
  # savior-* packages prefer the flake overlay (nixpkgs.overlays) and fall back to
  saviorSddm = pkgs.savior-sddm or (pkgs.callPackage ../pkgs/savior-sddm.nix { });
  saviorFonts = pkgs.savior-fonts or (pkgs.callPackage ../pkgs/fonts.nix { });
in {
  # Import the official Vicinae NixOS module when the input is provided, so the
  # input-server setuid wrapper can be wired automatically below.
  imports = lib.optionals (inputs ? vicinae) [ inputs.vicinae.nixosModules.default ];

  options.services.saviorDesktop = {
    enable = lib.mkEnableOption "Enable Savior NixOS System Desktop integration";

    sddm.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable SDDM display manager with Savior theme";
    };

    pipewire.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable PipeWire audio pipeline";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.services.saviorDesktop.enable {
    system.stateVersion = lib.mkDefault "24.05";

    # Hardware, Power & Security System Services
    security.polkit.enable = lib.mkDefault true;
    services.geoclue2.enable = lib.mkDefault true;
    services.power-profiles-daemon.enable = lib.mkDefault true;
    services.upower.enable = lib.mkDefault true;
    services.acpid.enable = lib.mkDefault true;

    # Network & Bluetooth
    networking.networkmanager.enable = lib.mkDefault true;
    hardware.bluetooth.enable = lib.mkDefault true;
    services.blueman.enable = lib.mkDefault true;

    # Kernel Modules for ACPI Call (for Hyprland and power management)
    boot.kernelModules = [ "acpi_call" ];
    boot.extraModulePackages = [ config.boot.kernelPackages.acpi_call ];

    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
      ];
      config.common.default = "*";
    };

    # Hyprland system-wide: ensures the wayland session entry exists for SDDM
    # (uses the pinned flake input, not just nixpkgs) and provides the portal config.
    programs.hyprland = {
      enable = lib.mkDefault true;
      package = lib.mkDefault (
        # Pinned flake input when present, otherwise the nixpkgs package
        if inputs ? hyprland
        then inputs.hyprland.packages.${pkgs.system}.hyprland
        else pkgs.hyprland
      );
      xwayland.enable = lib.mkDefault true;
    };

    # PipeWire Audio service: ALSA, PulseAudio
    services.pipewire = lib.mkIf config.services.saviorDesktop.pipewire.enable {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };
    # (/var/lib/savior-sddm/themes/savior) instead of the read-only store.
    # Matugen's sddm-theme-reload post-hook rewrites theme.conf + background.png
    services.displayManager = {
      defaultSession = lib.mkDefault "hyprland";
      sddm = lib.mkIf config.services.saviorDesktop.sddm.enable {
        enable = true;
        theme = "savior";
        wayland.enable = true;
        settings = {
          Theme = {
            ThemeDir = "/var/lib/savior-sddm/themes";
          };
        };
      };
    };

    # Seed the writable runtime theme dir from the store on every boot.
    # The `d` rule creates the parent; the `C` rule copies the savior theme
    # (0777 so the user's matugen post-hook can overwrite theme.conf/background.png)
    # only if it does not exist yet, preserving the last generated theme across reboots.
    systemd.tmpfiles.rules = lib.mkIf config.services.saviorDesktop.sddm.enable [
      "d /var/lib/savior-sddm/themes 0755 - - -"
      "C /var/lib/savior-sddm/themes/savior 0777 - - - ${saviorSddm}/share/sddm/themes/savior"
      "L+ /run/current-system/sw/share/sddm/themes/savior - - - - /var/lib/savior-sddm/themes/savior"
    ];

    # Register custom bundled fonts plus the project's standard font set system-wide
    fonts.packages = with pkgs; [
      saviorFonts
      noto-fonts-color-emoji
      cascadia-code
      nerd-fonts.fira-code
    ];

    # System-wide packages required for desktop environment
    environment.systemPackages = [
      saviorSddm
      pkgs.qt5.qtgraphicaleffects
      pkgs.qt6.qtdeclarative
      pkgs.qt6.qtsvg
    ];
    })
    (lib.optionalAttrs (inputs ? vicinae) {
      # Vicinae input-server setuid wrapper (auto-wired when the vicinae input is present)
      programs.vicinae.input-server.package = lib.mkDefault pkgs.vicinae;
    })
  ];
}
