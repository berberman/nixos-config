{ pkgs, config, global, ... }: {

  imports = [ ./hardware-configuration.nix ./secrets.nix ];

  networking.hostName = "POTATO-O0";

  networking.wireguard.interfaces = {
    wg0 = {
      inherit (global.wg.o0) ips listenPort peers;
      privateKeyFile = global.wg.o0.privateKeyFile config;
    };
  };
  networking.firewall.enable = false;
  services.v2ray = {
    enable = true;
    configFile = config.age.secrets.v2o0.path;
  };
  services.caddy = {
    enable = true;
    configFile = config.age.secrets.v2o0c.path;
  };
}
