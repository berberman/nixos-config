{ pkgs, ... }:

{

  programs.git = {
    enable = true;
    userName = "Potato Hatsue";
    userEmail = "1793913507@qq.com";
    signing = {
      key = "C4F93F1ED397E8CF";
      signByDefault = true;
    };
    ignores = [ ".envrc" ".direnv" ];
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
    });
  };

  home.file.".emacs".source = ./init.el;

  programs.home-manager.enable = true;
  programs.htop.enable = true;

  programs.gpg.enable = true;

  home.packages = with pkgs; [
    home-manager
    nixfmt-classic
    tdesktop
    slack
    vlc
    google-chrome
    element-desktop
    # feeluown
    weechat
    qbittorrent
    pavucontrol
    obs-studio
    discord
    jetbrains.idea-ultimate
    jetbrains.pycharm-professional
    haskellPackages.ghc
    haskellPackages.cabal-fmt
    texlive.combined.scheme-full
    tinymist
    wakatime
    elan
    (agda.withPackages (p: [ p.standard-library ]))
    zotero
    racket
    bitwarden
    typst
  ];

  # fcitx5 theme
  xdg.configFile."fcitx5/conf/classicui.conf".text = ''
    Vertical Candidate List=False

    PerScreenDPI=True

    Font="Noto Sans CJK SC 12"

    Theme=Material-Color-Indigo
  '';

 
  # ghci
  home.file.".ghc/ghci.conf".text = ''
    :set prompt "\ESC[38;5;208m\STXλ>\ESC[m\STX "
    :set -ferror-spans -freverse-errors -fprint-expanded-synonyms
  '';

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
      POTATO-HZ = { hostname = "hz.torus.icu"; };
      POTATO-DE = { hostname = "de.torus.icu"; };
      POTATO-O0 = {
        hostname = "o0.torus.icu";
        user = "root";
      };
      POTATO-O1 = {
        hostname = "o1.torus.icu";
        user = "root";
      };
      POTATO-OA = {
        hostname = "oa.torus.icu";
        user = "root";
      };
      ArchCN = {
        hostname = "build.archlinuxcn.org";
        user = "berberman";
      };
    };
  };

  home.stateVersion = "22.05";
}
