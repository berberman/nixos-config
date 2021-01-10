{ config, lib, pkgs, ... }:

{
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    binaryCaches =
      lib.mkBefore [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];
    trustedUsers = [ "root" "berberman" ];
  };

  nixpkgs.config.allowUnfree = true;

}
