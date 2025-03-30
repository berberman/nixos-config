{ config, pkgs, ... }:

{
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };

  services.displayManager = {
    sddm.enable = true;
    sddm.settings.General.DisplayServer = "x11-user";
    defaultSession = "plasmax11";
  };
  services.desktopManager.plasma6.enable = true;
  services.xserver = {
    enable = true;
    # use xmonad at user level 
    # windowManager.xmonad.enable = true;
    # displayManager.defaultSession = "plasma5+xmonad";

  };
}
