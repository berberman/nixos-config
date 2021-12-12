{ config, lib, pkgs, ... }:

{
 nix.binaryCaches = lib.mkBefore
      [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];
}

