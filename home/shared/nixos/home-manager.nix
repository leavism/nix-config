/*
 * Home-Manager Configurations for NixOS machines only
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
   # === NixOS Home-Manager Configurations ===
   programs = commonHomeManager // {
     # Overwrite and extend the common home manager configurations here
   };
 }
