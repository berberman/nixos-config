{ pkgs, ... }:

{
  imports = [ ./zsh.nix ./xmonad.nix ];

  programs.git = {
    enable = true;
    userName = "Potato Hatsue";
    userEmail = "1793913507@qq.com";
  };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [ WakaTime.vscode-wakatime ];
  };

  programs.home-manager.enable = true;
  programs.htop.enable = true;

  home.packages = with pkgs; [
    picom
    flameshot
    nixfmt
    tdesktop
    ark
    gwenview
    filelight
    okular
    peek
    wakatime
    haskellPackages.ormolu
    haskellPackages.ghc
    haskellPackages.cabal-fmt
    haskellPackages.cabal-plan
  ];

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
      background_opacity = 0.65;
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
}
