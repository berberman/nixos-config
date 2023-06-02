{ pkgs, lib, ... }:

{
  programs.starship.enable = true;
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "tmux" "systemd" "adb" "git" "colored-man-pages" "sudo" ];
      theme = "agnoster";
    };
  };
}
