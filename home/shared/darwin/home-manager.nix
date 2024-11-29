/*
 * Home-Manager Configurations for macOS nmachines only
 * https://nix-community.github.io/home-manager/index.xhtml
 *
 * Home Manager is a Nix-powered tool for reproducible management of the
 * contents of users’ home directories. This includes programs, configuration
 * files, environment variables and, well… arbitrary files.
 */

{ config, pkgs, lib, user,... }:
let
  commonHomeManager = import ../common/home-manager.nix { inherit config pkgs lib user; };
in
{
  # === macOS Home-Manager Configurations ===
  # To congifure the home-manager at the user level, go to /home/(username)/(hostname)
  programs = commonHomeManager // {
    # Overwrite and extend the common home manager configurations here
    # Overwrite Example:
    # git = commonHomeManager.git // { # Don't forget to merge into commonHomeManager.git
    #   userName = "Darwin Username";  # This overrides the common config
    # };
  };
}
