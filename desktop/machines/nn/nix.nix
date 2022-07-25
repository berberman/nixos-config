{ config, lib, pkgs, ... }:

{
  nix.settings.substituters =
    lib.mkBefore [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];
}

