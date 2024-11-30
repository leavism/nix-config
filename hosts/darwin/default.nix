{ config, pkgs, lib, user,... }:

let
  username = user.username;
  hostname = config.host;
  packages = import ../../home/${username}/packages.nix { inherit pkgs; };
in
{
  imports = [
    ../../home/shared/darwin
    ../../home/shared/darwin/dock
  ];

  # It me
  users.users.${username} = {
    name = "${username}";
    home = "/Users/${username}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  homebrew = packages.homebrewPackages;
  environment.systemPackages = packages.systemPackages;
  services.nix-daemon.enable = true;

  nix = {
    package = pkgs.nix;
    settings = {
      trusted-users = [ "@admin" "${username}" ];
      substituters = [ "https://nix-community.cachix.org" "https://cache.nixos.org" ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
    };

    gc = {
      user = "root";
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 30d";
    };

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # === Configure System Settings ===
  system = {
    checks.verifyNixPath = false;
    stateVersion = 4;

    defaults = {
      NSGlobalDomain = {
        KeyRepeat = 2; # Values: 120, 90, 60, 30, 12, 6, 2
        InitialKeyRepeat = 15; # Values: 120, 94, 68, 35, 25, 15
      };

      dock = {
        autohide = true;
        show-recents = false;
        launchanim = true;
        orientation = "left";
        tilesize = 45;
      };
    };
  };

  # Fully declarative dock using the latest from Nix Store
  local.dock.enable = true;
  local.dock.entries = [
    { path = "/System/Applications/Messages.app/"; }
    { path = "/System/Applications/Music.app/"; }
    {
      path = "${config.users.users.${user.name}.home}/Downloads";
      section = "others";
      options = "--sort name --view grid --display stack";
    }
  ];
}
