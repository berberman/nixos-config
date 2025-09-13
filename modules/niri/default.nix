{ lib, config, pkgs, ... }:

{
  options.enableNiri = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable Niri desktop environment.";
  };
  options.niriExtra = lib.mkOption {
    type = lib.types.str;
    default = "";
    description = "Extra niri config";
  };
  config = lib.mkIf config.enableNiri {
    programs.nm-applet.enable = true;
    niri-flake.cache.enable = true;
    programs.niri = {
      enable = true;
      # package = pkgs.niri;
    };
    environment.variables = {
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      NIXOS_OZONE_WL = "1";
      ELECTRON_ENABLE_WAYLAND_IME = "1";
    };
    services.displayManager.gdm.enable = true;
    services.udisks2.enable = true;
    environment.systemPackages = (with pkgs; [
      wl-clipboard
      wayland-utils
      xwayland-satellite
      grim
      slurp
      swww
    ]) ++ (with pkgs.kdePackages; [
      dolphin
      ark
      gwenview
      okular
      kate
      kgpg
      kdeconnect-kde
      konsole
      kservice
      qtwayland
      kdegraphics-thumbnailers
      qtsvg
      kio
      kio-extras
      dolphin-plugins
    ]);

    xdg.portal = with pkgs; {
      enable = true;
      extraPortals = [ xdg-desktop-portal-gnome xdg-desktop-portal-gtk ];
    };

    bhome = {
      programs.niri.config = let base = builtins.readFile ./config.kdl;
      in ''
        ${base}
        ${config.niriExtra}
      '';
      programs.fuzzel.enable = true;
      programs.swaylock.enable = true;
      services.swaync.enable = true;
      programs.waybar.enable = true;

      xdg.configFile."waybar/config.jsonc".source = ./config.jsonc;
      xdg.configFile."waybar/style.css".source = ./style.css;

      home.pointerCursor = {
        gtk.enable = true;
        name = "Numix-Cursor-Light";
        package = pkgs.numix-cursor-theme;
      };

      xdg.configFile."menus/applications.menu".text = builtins.readFile
        "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

      qt = {
        enable = true;
        style = {
          name = "breeze";
          package = pkgs.kdePackages.breeze;
        };
        platformTheme.name = "kde";
      };

      gtk = {
        enable = true;
        theme.name = "Breeze";
        theme.package = pkgs.kdePackages.breeze-gtk;
        iconTheme = {
          name = "Papirus";
          package = pkgs.papirus-icon-theme;
        };
        cursorTheme = {
          name = "Numix-Cursor-Light";
          package = pkgs.numix-cursor-theme;
        };
        font = {
          name = "Noto Sans";
          size = 11;
        };
        gtk2.extraConfig = ''gtk-im-module = "fcitx"'';

        gtk3.extraConfig = {
          gtk-im-module = "fcitx";
          gtk-application-prefer-dark-theme = false;
        };

        gtk4.extraConfig = {
          gtk-im-module = "fcitx";
          gtk-application-prefer-dark-theme = false;
        };
      };
    };
  };
}
