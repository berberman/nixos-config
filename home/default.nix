{ pkgs, ... }:

{
  imports = [ ./zsh.nix ./xmonad.nix ];

  programs.git = {
    enable = true;
    userName = "Potato Hatsue";
    userEmail = "1793913507@qq.com";
    signing = {
      key = "C4F93F1ED397E8CF";
      signByDefault = true;
    };

  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.vscode = {
    enable = true;
#     extensions = with pkgs.vscode-extensions; [ WakaTime.vscode-wakatime ];
  };

  programs.emacs = {
    enable = true;
    package = (pkgs.emacsWithPackagesFromUsePackage {
      package = pkgs.emacs;
      alwaysEnsure = true;
      extraEmacsPackages = p: with p; [ use-package ];
      config = ./init.el;
      override = epkgs: epkgs // {
      telega = epkgs.melpaPackages.telega.override {
          tdlib = pkgs.tdlib.overrideAttrs (old: rec {
            version = "1.8.0";
            src = pkgs.fetchFromGitHub {
              owner = "tdlib";
              repo = "td";
              rev = "v${version}";
              sha256 = "OBgzFBi+lIBbKnHDm5D/F3Xi4s1x4geb+1OoBP3F+qY=";
            };
          });
        };
      };
    });
  };

  home.file.".emacs".source = ./init.el;

  programs.home-manager.enable = true;
  programs.htop.enable = true;

  programs.gpg.enable = true;

  home.packages = with pkgs; [
    home-manager
    picom
    flameshot
    nixfmt
    postman
    tdesktop
    ark
    gwenview
    filelight
    okular
    peek
    enpass
    slack
    vlc
    kate
    kgpg
    google-chrome
    ncdu
    element-desktop
    clementine
    feeluown
    weechat
    qbittorrent
    pavucontrol
    obs-studio
    discord
    jetbrains.idea-ultimate
    jetbrains.pycharm-professional
    fastocr
    proxychains
    haskellPackages.ghc
    haskellPackages.cabal-fmt
    haskellPackages.cabal-plan
    mathematica
    netbeans
    texlive.combined.scheme-full
    wakatime
    (agda.withPackages (p: [ p.standard-library ]))
    zotero
    racket
  ];

  # fcitx5 theme
  xdg.configFile."fcitx5/conf/classicui.conf".text = ''
    Vertical Candidate List=False

    PerScreenDPI=True

    Font="Noto Sans CJK SC 12"

    Theme=Material-Color-Indigo
  '';

  # proxychains config
  home.file.".proxychains/proxychains.conf".text = ''
    strict_chain

    proxy_dns 

    remote_dns_subnet 224

    tcp_read_time_out 15000
    tcp_connect_time_out 8000

    localnet 127.0.0.0/255.0.0.0

    [ProxyList]
    socks5 192.168.31.88 1080
  '';

  # ghci
  home.file.".ghc/ghci.conf".text = ''
    :set prompt "\ESC[38;5;208m\STXλ>\ESC[m\STX "
    :set -ferror-spans -freverse-errors -fprint-expanded-synonyms
  '';

  # picom
  xdg.configFile."picom.conf".source = ./picom.conf;

  # rofi
  programs.rofi.enable = true;

  # adi1090x/rofi theme 
  xdg.configFile."rofi/colorful/style.rasi".source = ./style.rasi;

  # alacritty
  programs.alacritty = {
    enable = true;
    # vscode terminal style
    settings = {
      window.opacity = 0.65;
      colors = {
        primary.background = "#1e1e1e";
        normal = {
          black = "#000000";
          red = "#cd3131";
          green = "#0dbc79";
          yellow = "#e5e510";
          blue = "#2472c8";
          magenta = "#bc3fbc";
          cyan = "#11a8cd";
          white = "#e5e5e5";
        };
        bright = {
          black = "#666666";
          red = "#f14c4c";
          green = "#23d18b";
          yellow = "#f5f543";
          blue = "#3b8eea";
          magenta = "#d670d6";
          cyan = "#29b8db";
          white = "#e5e5e5";
        };
      };
    };
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      PVE = {
        hostname = "192.168.31.10";
        user = "root";
      };
      OpenWRT = {
        hostname = "192.168.31.1";
        user = "root";
      };
      POTATO-A = { hostname = "192.168.31.88"; };
      POTATO-HZ = { hostname = "hz.typed.icu"; };
      POTATO-DE = { hostname = "de.berberman.space"; };

    };
  };
}
