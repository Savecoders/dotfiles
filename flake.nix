
{
  description = "Savior Dotfiles Flake for NixOS and Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    vicinae = {
      url = "github:vicinaehq/vicinae";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # AwesomeWM Git Submodules
    bling = {
      url = "github:BlingCorp/bling";
      flake = false;
    };

    layout-machi = {
      url = "github:xinhaoyuan/layout-machi";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, quickshell, hyprland, vicinae, ... }@inputs:
  let
    system = "x86_64-linux";

   detectedUser = builtins.getEnv "USER";
    username = if detectedUser != "" then detectedUser else "save";

    stateVersion = "26.05";

    overlay = import ./nix/overlays/default.nix inputs;

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [ overlay ];
    };
  in {
    # Custom package overlay (savior-*)
    overlays.default = overlay;

    formatter.${system} = pkgs.nixpkgs-fmt;

    # Development shell with Nix tooling
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        nixpkgs-fmt
        nixd
        statix
      ];
    };

    homeManagerModules.default = ./nix/home/default.nix;
    homeManagerModules.saviorDotfiles = self.homeManagerModules.default;
    nixosModules.default = ./nix/modules/default.nix;
    nixosModules.saviorDesktop = self.nixosModules.default;

    packages.${system} = rec {
      savior-fonts = pkgs.savior-fonts;
      savior-sddm = pkgs.savior-sddm;
      savior-themes-and-icons = pkgs.savior-themes-and-icons;
      savior-shell = pkgs.savior-shell;
      default = savior-shell;
    };

    # Standalone Home Manager Configuration
    # Output name matches $USER automatically -> `home-manager switch --flake .#$(whoami) --impure`
    homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit inputs; };
      modules = [
        self.homeManagerModules.default
        {
          home.username = username;
          home.homeDirectory = "/home/${username}";
          home.stateVersion = stateVersion;

          programs.saviorDotfiles = {
            enable = true;
            wm.hyprland.enable = true;
            wm.awesome.enable = true;
            quickshell.enable = true;
            matugen.enable = true;
          };
        }
      ];
    };

    # Complete NixOS System Configuration
    nixosConfigurations."desktop" = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        {
          nixpkgs.config.allowUnfree = true;
        }
        {
          nixpkgs.overlays = [ self.overlays.default ];
        }
        self.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          services.saviorDesktop.enable = true;

          # Creates the actual Linux account for $USER; without this, home-manager
          # would be managing a user that doesn't exist on the system.
          users.users.${username} = {
            isNormalUser = true;
            description = username;
            extraGroups = [ "networkmanager" "wheel" "audio" "video" ];
            shell = pkgs.zsh;
          };

          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = {
            imports = [ self.homeManagerModules.default ];
            home.stateVersion = stateVersion;
            programs.saviorDotfiles.enable = true;
          };
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
      ];
    };
  };
}
