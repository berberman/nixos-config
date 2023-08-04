{ pkgs, config, global, ... }: {
  imports =
    [ ./hardware-configuration.nix ./secrets.nix ./matrix.nix ./znc.nix ];

  networking.hostName = "POTATO-OA";
  networking.firewall.enable = false;
  networking.interfaces.ens3.useDHCP = true;
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "acme@typed.icu";
  boot.zfs.devNodes = "/dev";
  networking.hostId = "c271c48d";
  networking.wireguard.interfaces = {
    wg0 = {
      inherit (global.wg.oa) ips listenPort peers;
      privateKeyFile = global.wg.oa.privateKeyFile config;
    };
  };
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
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
  };
}
