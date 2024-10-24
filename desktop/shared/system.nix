{ config, pkgs, ... }:

{

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    configPackages = [
      (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/10-roc-source.conf" ''
        context.modules = [
         {   name = libpipewire-module-roc-source
             args = {
                 local.ip = 0.0.0.0
                 resampler.profile = medium
                 fec.code = rs8m
                 sess.latency.msec = 100
                 local.source.port = 10001
                 local.repair.port = 10002
                 source.name = "ROC Source"
                 source.props = {
                    node.name = "roc-source"
                 }
             }
        }
        ]
      '')
    ];
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

  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ];
  };

  services.gnome.gnome-keyring.enable = true;

  programs.java = {
    enable = true;
    package = pkgs.jdk17;
  };

  programs.adb.enable = true;

  programs.mosh.enable = true;

  programs.kdeconnect.enable = true;

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

  # https://github.com/dramforever/config/commit/1f3030741ed1d3f6a0af1b61cfa0016083917b58#diff-a1dca4d3e1eda4c2afcfd8301ee3b4ae9363de1d9130966e1a2bd5048aba9c37R47
  environment.variables.QT_PLUGIN_PATH = let
    fcitx5Workaround = pkgs.runCommand "fcitx5-workaround" { } ''
      plugins="${config.i18n.inputMethod.package}/${pkgs.qt6.qtbase.qtPluginPrefix}"
      cp -r --dereference "$plugins" $out
    '';
  in [ "${fcitx5Workaround}" ];

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
    pciutils
    pcsctools
    yubikey-personalization
    yubikey-personalization-gui
    remmina
    tmux
    # nyx
    # tor-browser-bundle-bin
    bind
    file
    tree
    typst
  ];

  services.tailscale.enable = true;
  # services.tor = {
  #   enable = true;
  #   client.enable = true;
  #   settings.ControlPort = 9051;
  # };
}
