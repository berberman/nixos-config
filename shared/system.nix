{ config, pkgs, ... }:

{

  sound.enable = true;

  hardware.pulseaudio.enable = true;

  services.openssh.enable = true;

  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ];
  };

  services.gnome.gnome-keyring.enable = true;

  programs.java = {
    enable = true;
    package = pkgs.jdk8;
  };

  programs.adb.enable = true;

  i18n.inputMethod = {
    enabled = "fcitx5";

    fcitx5.addons = with pkgs; [
      fcitx5-chinese-addons
      fcitx5-mozc
      fcitx5-material-color
      fcitx5-pinyin-zhwiki
      fcitx5-pinyin-moegirl
    ];
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
    zsh
    gparted
    ripgrep
    kdeconnect
  ];

}
