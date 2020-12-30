{ config, pkgs, ... }:

{
  fonts = {
    fontconfig.defaultFonts = {
      monospace = [ "Cascadia Code" ];
      sansSerif = [ "Noto Sans CJK SC" ];
      serif = [ "Noto Sans CJK SC" ];
    };
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      cascadia-code
      symbola
    ];
  };
}
