{ config, pkgs, lib, home-manager, user, ... }:

let
    username = user.name;
in
{
  # Extend home-manager from flake.nix
  home = {
    enableNixpkgsReleaseCheck = false;
    packages = [];
    stateVersion = "23.11";
  };

  programs = {} // import ../common/darwin/home-manager.nix { inherit config pkgs lib user; };

  # Marked broken Oct 20, 2022 check later to remove this
  manual.manpages.enable = false;
}
