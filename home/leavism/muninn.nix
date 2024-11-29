{ config, pkgs, lib, home-manager, user, ... }:
let
  darwinHomeManager = import ../shared/darwin/home-manager.nix { inherit config pkgs lib user; };
  packages = import ./packages.nix { inherit pkgs; hostname = "muninn"; };
in
{
  # === User-level home-manager Configurations ===
  home = {
    enableNixpkgsReleaseCheck = false;
    packages = packages.userPackages;
    stateVersion = "23.11";
  };

  # === User-level Home-Manager Configurations ===
  # To congifure the home-manager at the platform or cross-platform level,
  # go to /home/(platform)/home-manager.nix or /home/shared/home-manager.nix
  # repsectively.
  programs = darwinHomeManager.programs // {
    # Overwrite and extend the darwin home manager configurations here
    # Example:
    # git = darwinHomeManager.git // { # Don't forget to merge into darwinHomeManager.git
    #   userName = "muninn Username";  # This overrides the darwin config
    # };
  };

  # Marked broken Oct 20, 2022 check later to remove this
  manual.manpages.enable = false;
}
