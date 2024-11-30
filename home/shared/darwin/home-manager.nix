/*
 * Home-Manager Configurations for macOS nmachines only
 * https://nix-community.github.io/home-manager/index.xhtml
 *
 * To congifure the home-manager at the user level, go to /home/(username)/(hostname).nix.
 * To configure the home-manager at the cross-platform level, go to /home/shared/common/home-manager.nix.
 */
{ config, pkgs, lib, user,... }:
let
  commonHomeManager = import ../common/home-manager.nix { inherit config pkgs lib user; };
in
{
  programs = commonHomeManager // {
    # Overwrite and extend the common home manager configurations here
    # Overwrite Example:
    # git = commonHomeManager.git // { # Don't forget to merge into commonHomeManager.git
    #   userName = "Darwin Username";  # This overrides the common config
    # };
  };
}
