{ config, pkgs, ... }:

{
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };
  services.displayManager.sddm.enable = true;
  services.xserver = {
    enable = true;
    desktopManager.plasma5.enable = true;
    # https://gist.github.com/mageta/dd5a3ca951f26137d63dadb0b92f6027
    desktopManager.plasma5.runUsingSystemd = false;

    # use xmonad at user level 
    # windowManager.xmonad.enable = true;
    # displayManager.defaultSession = "plasma5+xmonad";

  };
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "xmonad";
}
