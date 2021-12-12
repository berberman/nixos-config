{ config, lib, pkgs, ... }:

{
  nix = {
    package = pkgs.nixFlakes;
    nixPath = [ "nixpkgs=${pkgs.path}" ];
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
    autoOptimiseStore = true;
    trustedUsers = [ "root" "berberman" ];
  };

  nixpkgs.config.allowUnfree = true;

}
