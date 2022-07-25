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
    settings = {
      trusted-users = [ "root" "berberman" ];
      auto-optimise-store = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

}
