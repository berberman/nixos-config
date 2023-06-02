{ pkgs, config, global, ... }: {

  imports = [ ./hardware-configuration.nix ./secrets.nix ];

  networking.hostName = "POTATO-O0";

  services.ircbot = {
    enable = true;
    nick = "libido";
    passwordFile = pkgs.writeTextFile {
      name = "libido-password";
      text = "12345";
    };
    channels = [ "##archlinux-cn-nsfw" ];
    pixivTokenFile = config.age.secrets.pixiv-token.path;
    googleKeyFile = config.age.secrets.google-key.path;
    googleCxFile = config.age.secrets.google-cx.path;
    telegraphTokenFile = config.age.secrets.telegraph-token.path;
  };

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
