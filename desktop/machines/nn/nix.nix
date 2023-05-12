{ config, lib, pkgs, ... }:

{
  nix.settings = {
    substituters =
      lib.mkBefore [ "https://mirrors.bfsu.edu.cn/nix-channels/store" ];
  };
}

