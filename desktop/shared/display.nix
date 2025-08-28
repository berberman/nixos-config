{ config, pkgs, lib, ... }:

{
  options.kdeVersion = lib.mkOption {
    type = lib.types.enum [ "5" "6" ];
    default = "6";
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
        sddm-kcm
      ];
  in lib.mkMerge [
    # Use X11 for KDE 5
    (lib.mkIf (config.kdeVersion == "5") {
      services.displayManager.sddm.enable = true;
      services.xserver.enable = true;
      services.xserver.desktopManager.plasma5.enable = true;
      services.xserver.desktopManager.plasma5.runUsingSystemd = false;
      environment.systemPackages = extraKDEPackages pkgs.plasma5Packages;
      xdg.portal.extraPortals = [ pkgs.plasma5Packages.xdg-desktop-portal-kde ];
    })
    # Use Wayland for KDE 6
    (lib.mkIf (config.kdeVersion == "6") {
      services.desktopManager.plasma6.enable = true;
      services.displayManager.sddm.enable = true;
      services.displayManager.sddm.wayland.enable = true;
      services.displayManager.sddm.settings.General.DisplayServer = "wayland";
      environment.systemPackages = extraKDEPackages pkgs.kdePackages;
      xdg.portal.extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
      i18n.inputMethod.fcitx5.waylandFrontend = true;
    })
    {
      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        config.common.default = "*";
      };

    }
  ];
}
