{ config, pkgs, ... }:

{

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    # configPackages = [
    #   (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/10-roc-source.conf" ''
    #     context.modules = [
    #      {   name = libpipewire-module-roc-source
    #          args = {
    #              local.ip = 0.0.0.0
    #              resampler.profile = medium
    #              fec.code = rs8m
    #              sess.latency.msec = 100
    #              local.source.port = 10001
    #              local.repair.port = 10002
    #              source.name = "ROC Source"
    #              source.props = {
    #                 node.name = "roc-source"
    #              }
    #          }
    #     }
    #     ]
    #   '')
    # ];
  };

  services.openssh.enable = true;
  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  programs = {
    ssh.startAgent = false;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.printing = {
    enable = true;
    drivers = with pkgs; [ hplip cups-filters cups-browsed ];
  };

  services.gnome.gnome-keyring.enable = true;

  programs.java = {
    enable = true;
    package = pkgs.jdk17;
  };

  programs.adb.enable = true;

  programs.mosh.enable = true;

  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;

    fcitx5.addons = with pkgs; [
      fcitx5-chinese-addons
      fcitx5-mozc
      fcitx5-material-color
      fcitx5-pinyin-zhwiki
      fcitx5-pinyin-moegirl
    ];
  };

  environment.systemPackages = with pkgs; [
    helvum
    wget
    vim
    firefox
    htop
    bat
    rsync
    fastfetch
    git
    zsh
    gparted
    ripgrep
    pciutils
    pcsctools
    yubikey-personalization
    yubioath-flutter
    remmina
    tmux
    # nyx
    # tor-browser-bundle-bin
    bind
    file
    tree
    ncdu
    unrar
  ];

  services.tailscale.enable = true;
  # services.tor = {
  #   enable = true;
  #   client.enable = true;
  #   settings.ControlPort = 9051;
  # };
  programs.nix-ld.enable = true;

}
