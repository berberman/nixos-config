{ config, pkgs, ... }:

{
  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "VictorMono Nerd Font" "Noto Sans CJK SC" ];
        sansSerif = [ "Noto Sans" "Noto Sans CJK SC" ];
        serif = [ "Noto Serif" "Noto Serif CJK SC" ];
        emoji = [ "Apple Color Emoji" ];
      };
    };
    packages = with pkgs; [
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      apple-emoji
      (nerdfonts.override { fonts = [ "CascadiaCode" "VictorMono"]; })
      cascadia-code
      liberation_ttf
      freefont_ttf
      victor-mono
    ];
  };
}
