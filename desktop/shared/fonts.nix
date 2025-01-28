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
      cascadia-code
      nerd-fonts.caskaydia-cove
      liberation_ttf
      freefont_ttf
      victor-mono
      nerd-fonts.victor-mono
    ];
  };
}
