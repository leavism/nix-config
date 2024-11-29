{
  description = "Starter Configuration for MacOS and NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative tap management
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    aerospace = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };
  };

  # Add your tap into the outputs
  outputs = { self, darwin, nix-homebrew, homebrew-bundle, homebrew-core, homebrew-cask, home-manager, aerospace, nixpkgs, disko } @inputs:
    let
      # Define users and their configurations
      users = {
        leavism = {
          name = "leavism";
          email = "ghuydang@gmail.com";
          fullName = "Huy Dang";
        };
      };

      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      darwinSystems = [ "aarch64-darwin" "x86_64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) f;

      devShell = system: let pkgs = nixpkgs.legacyPackages.${system}; in {
        default = with pkgs; mkShell {
          nativeBuildInputs = with pkgs; [ bashInteractive git ];
          shellHook = with pkgs; ''
            export EDITOR=vim
          '';
        };
      };

      mkApp = scriptName: system: {
        type = "app";
        program = "${(nixpkgs.legacyPackages.${system}.writeScriptBin scriptName ''
          #!/usr/bin/env bash
          PATH=${nixpkgs.legacyPackages.${system}.git}/bin:$PATH
          echo "Running ${scriptName} for ${system}"
          exec ${self}/apps/${system}/${scriptName} "$@"
        '')}/bin/${scriptName}";
      };

      mkLinuxApps = system: {
        "apply" = mkApp "apply" system;
        "build-switch" = mkApp "build-switch" system;
        "copy-keys" = mkApp "copy-keys" system;
        "create-keys" = mkApp "create-keys" system;
        "check-keys" = mkApp "check-keys" system;
        "install" = mkApp "install" system;
      };

      mkDarwinApps = system: {
        "apply" = mkApp "apply" system;
        "build" = mkApp "build" system;
        "build-switch" = mkApp "build-switch" system;
        "copy-keys" = mkApp "copy-keys" system;
        "create-keys" = mkApp "create-keys" system;
        "check-keys" = mkApp "check-keys" system;
        "rollback" = mkApp "rollback" system;
      };

      # Helper function to create Darwin configuration
      mkDarwinConfig = hostname: username: let
        system = "aarch64-darwin";
        user = users.${username};
      in darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {
          inherit inputs hostname user;
        };
        modules = [
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              user = username;
              enable = true;
              taps = {
                # Prepend the repo part of all taps with "homebrew-".
                # ex: nikitabobko/HOMEBREW-tap
                # Don't forget to declare your taps in inputs and outputs too.
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "homebrew/homebrew-bundle" = homebrew-bundle;
                "nikitabobko/homebrew-tap" = inputs.aerospace;
              };
              mutableTaps = false; # Declarative taps
              autoMigrate = true;
            };
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit user; };
              users.${username} = import ./home/${username}/${hostname}.nix;
            };
          }
          ./hosts/darwin/${hostname}.nix
        ];
      };

      # Helper function to create NixOS configuration
      mkNixosConfig = hostname: username: let
        system = "x86_64-linux";
        user = users.${username};
      in nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs hostname user;
        };
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit user; };
              users.${username} = import ./home/${username}/${hostname}.nix;
            };
          }
          ./hosts/nixos/${hostname}.nix
        ];
      };
    in
    {
      devShells = forAllSystems devShell;
      apps = nixpkgs.lib.genAttrs linuxSystems mkLinuxApps // nixpkgs.lib.genAttrs darwinSystems mkDarwinApps;

      darwinConfigurations = {
        default = mkDarwinConfig "default" "leavism";
        muninn = mkDarwinConfig "muninn" "leavism";
        odin = mkDarwinConfig "odin" "leavism";
      };

      nixosConfigurations = {
        default = mkNixosConfig "default" "leavism";
      };
    };
}
