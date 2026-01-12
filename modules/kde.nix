{ config, pkgs, lib, ... }:

{
  options.enableKDE = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable KDE desktop environment.";
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
        kimageformats
      ];
  in lib.mkIf config.enableKDE ({
    services.desktopManager.plasma6.enable = true;
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.displayManager.sddm.settings.General.DisplayServer = "wayland";
    environment.systemPackages = extraKDEPackages pkgs.kdePackages;
    xdg.portal.extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    i18n.inputMethod.fcitx5.waylandFrontend = true;
  } // {
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      config.common.default = "*";
    };
  });

}
