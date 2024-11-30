/*
 * Home-Manager Configurations for the 'muninn' macOS machine
 * https://nix-community.github.io/home-manager/index.xhtml
 *
 * This is the user-level home-manager configurations and can overwrite
 * or extend any home-manager configurations at the darwin or cross-platform
 * level. To directly change the configurations at these levels, go to
 * /home/(platform)/home-manager.nix or /home/shared/home-manager.nix respectively.
 */
{ config, pkgs, lib, home-manager, user, ... }:
let
  darwinHomeManager = import ../shared/darwin/home-manager.nix { inherit config pkgs lib user; };
  packages = import ./packages.nix { inherit pkgs; hostname = "muninn"; };
in
{
  home = {
    enableNixpkgsReleaseCheck = false;
    packages = packages.userPackages;
    stateVersion = "23.11";
  };

  programs = darwinHomeManager.programs // {
    # Overwrite and extend the darwin home-manager configurations here
    # Example:
    # git = darwinHomeManager.git // { # Don't forget to merge into darwinHomeManager.git
    #   userName = "muninn Username";  # This overrides the darwin config
    # };
  };

  # Marked broken Oct 20, 2022 check later to remove this
  manual.manpages.enable = false;
}
