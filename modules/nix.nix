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
    binaryCaches = lib.mkBefore
      [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];
    trustedUsers = [ "root" "berberman" ];
  };

  nixpkgs.config.allowUnfree = true;

}
