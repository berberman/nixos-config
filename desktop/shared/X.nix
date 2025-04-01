{ config, pkgs, lib, ... }:

{
  options.kdeVersion = lib.mkOption {
    type = lib.types.enum [ "5" "6" ];
    default = "5";
  };

  config = let
    extraKDEPackages = p:
      with p; [
        ark
        gwenview
        okular
        kate
        kgpg
        kdeconnect-kde
      ];
  in lib.mkMerge [
    (lib.mkIf (config.kdeVersion == "5") {
      services.xserver.desktopManager.plasma5.enable = true;
      services.xserver.desktopManager.plasma5.runUsingSystemd = false;
      environment.systemPackages = extraKDEPackages pkgs.plasma5Packages;
      xdg.portal.extraPortals = [ pkgs.plasma5Packages.xdg-desktop-portal-kde ];
    })
    (lib.mkIf (config.kdeVersion == "6") {
      services.displayManager.sddm.settings.General.DisplayServer = "x11-user";
      services.displayManager.defaultSession = "plasmax11";
      services.desktopManager.plasma6.enable = true;
      environment.systemPackages = extraKDEPackages pkgs.kdePackages;
      xdg.portal.extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    })
    {
      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        config.common.default = "*";
      };

      services.displayManager.sddm.enable = true;
      services.xserver.enable = true;
    }
  ];
}
