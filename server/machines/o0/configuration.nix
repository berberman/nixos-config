{ pkgs, config, ... }: {

  imports = [ ./hardware-configuration.nix ./ircbot.nix ];

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

}
