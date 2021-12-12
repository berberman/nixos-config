{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
    videoDrivers = [ "nvidia" ];

    # use xmonad at user level 
    # windowManager.xmonad.enable = true;
    # displayManager.defaultSession = "plasma5+xmonad";

  };
}
