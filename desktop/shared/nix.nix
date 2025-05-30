{ config, lib, pkgs, inputs, ... }:

{
  nix = {
    package = pkgs.nixVersions.latest;
    nixPath = [ "nixpkgs=${pkgs.path}" ];
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
      !include ${config.age.secrets.github-token.path}
    '';
    settings = {
      trusted-users = [ "root" "berberman" ];
      auto-optimise-store = true;
    };
    registry.nixpkgs.flake = inputs.nixpkgs;
  };

  nixpkgs.config.allowUnfree = true;

}
