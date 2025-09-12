{ lib, config, pkgs, ... }:
let cfg = config.services.zerotier;
in {
  options.services.zerotier.enable = lib.mkEnableOption "Enable ZeroTier";
  config = lib.mkIf cfg.enable {
    services.zerotierone = {
      enable = true;
      joinNetworks = [ "bb720a5aaea0720a" ];
    };
  };
}
