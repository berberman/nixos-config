{ config, pkgs, ... }:

{
  fonts = {
    fontconfig.defaultFonts = {
      monospace = [ "Caskaydia Cove Nerd Font" ];
      sansSerif = [ "Noto Sans CJK SC" ];
      serif = [ "Noto Sans CJK SC" ];
    };
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
      cascadia-code
      symbola
    ];
  };
}
