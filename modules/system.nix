{ config, pkgs, ... }:

{
  time.timeZone = "Asia/Shanghai";

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services.openssh.enable = true;

  i18n.inputMethod = {
    enabled = "fcitx";
    fcitx.engines = with pkgs.fcitx-engines; [ rime ];
  };

  environment.systemPackages = with pkgs; [
    wget
    vim
    firefox
    htop
    bat
    rsync
    neofetch
    git
  ];

}
