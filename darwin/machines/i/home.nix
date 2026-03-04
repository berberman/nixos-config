{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Potato Hatsue";
        email = "1793913507@qq.com";
      };
    };
    signing = {
      key = "C4F93F1ED397E8CF";
      signByDefault = true;
    };
    ignores = [
      ".envrc"
      ".direnv"
    ];
  };
  programs.htop.enable = true;

  programs.gpg.enable = true;
  programs.starship.enable = true;
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "tmux"
        "systemd"
        "git"
        "colored-man-pages"
        "sudo"
      ];
    };
  };
  home.packages = with pkgs; [
    nixfmt
    haskellPackages.ghc
    haskellPackages.cabal-fmt
    elan
    tinymist
    (
      let
        rocqPkgs = rocqPackages_9_0;
      in
      (symlinkJoin {
        name = "rocq-dev-env";
        buildInputs = [ makeWrapper ];
        paths = with rocqPkgs; [
          vsrocq-language-server
          rocq-core
        ];
        postBuild = ''
          LIB="${rocqPkgs.stdlib}/lib/coq/9.0/user-contrib"
          wrapProgram $out/bin/rocq \
            --set ROCQPATH $LIB
          wrapProgram $out/bin/vsrocqtop \
            --set ROCQPATH $LIB
        '';
      })
    )
  ];

  # alacritty
  programs.alacritty = {
    enable = true;
    # vscode terminal style
    settings = {
      window.opacity = 0.65;
      font.size = 14;
      font.normal.family = "VictorMono Nerd Font";
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

  home.stateVersion = "26.05";

}
