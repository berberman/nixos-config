{ config, pkgs, ... }:

{
  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "Caskaydia Cove Nerd Font" ];
        sansSerif = [ "Noto Sans CJK SC" ];
        serif = [ "Noto Serif CJK SC" ];
        emoji = [ "Apple Color Emoji" ];
      };
    };
    fonts = with pkgs; [
      noto-fonts-cjk
      apple-emoji
      (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
      cascadia-code
      liberation_ttf
      freefont_ttf
    ];
  };
}
