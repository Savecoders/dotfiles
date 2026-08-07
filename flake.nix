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
    homeConfigurations =
      let
        username = let u = builtins.getEnv "USER"; in if u != "" then u else "save";
        homeDir = let h = builtins.getEnv "HOME"; in if h != "" then h else "/home/${username}";
        mkHomeConfig = user: dir: home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs; };
          modules = [
            self.homeManagerModules.default
            {
              home.username = lib.mkDefault user;
              home.homeDirectory = lib.mkDefault dir;
              home.stateVersion = lib.mkDefault "24.05";
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
      in {
        "${username}" = mkHomeConfig username homeDir;
        "save" = mkHomeConfig "save" "/home/save";
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
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.save = {
            imports = [ self.homeManagerModules.default ];
            programs.saviorDotfiles.enable = true;
          };
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
      ];
    };
  };
}
