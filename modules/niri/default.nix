{ lib, config, pkgs, ... }:

let cfg = config.niri;
in {
  options.niri = {
    enable = lib.mkEnableOption "Enable niri components.";
    ex = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Extra niri config";
    };
  };
  config = lib.mkIf cfg.enable {
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

    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.displayManager.sddm.settings.General.DisplayServer = "wayland";

    services.udisks2.enable = true;
    environment.systemPackages = (with pkgs; [
      wl-clipboard
      wayland-utils
      xwayland-satellite
      grim
      slurp
      swww
      brightnessctl
      nautilus
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
      kio-admin
      dolphin-plugins
      kde-cli-tools
    ]);

    xdg.portal = with pkgs; {
      enable = true;
      extraPortals = [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
    };

    environment.etc."nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json".text =
      lib.mkIf (lib.elem "nvidia" config.services.xserver.videoDrivers) ''
        {
            "rules": [
                {
                    "pattern": {
                        "feature": "procname",
                        "matches": "niri"
                    },
                    "profile": "Limit Free Buffer Pool On Wayland Compositors"
                }
            ],
            "profiles": [
                {
                    "name": "Limit Free Buffer Pool On Wayland Compositors",
                    "settings": [
                        {
                            "key": "GLVidHeapReuseRatio",
                            "value": 0
                        }
                    ]
                }
            ]
        }
      '';

    _bhome.imports = [{
      programs.niri.config = let base = builtins.readFile ./niri-config.kdl;
      in ''
        ${base}
        ${cfg.ex}
      '';
      services.clipse = {
        enable = true;
        theme = builtins.readFile ./clipse-theme.json;
      };

      programs.fuzzel.enable = true;
      programs.swaylock = {
        enable = true;
        package = pkgs.swaylock-effects;
        settings = {
          screenshots = true;
          clock = true;
          indicator = true;
          indicator-radius = 100;
          indicator-thickness = 7;
          effect-blur = "7x5";
          fade-in = 1.0;
          grace = 5;
          grace-no-mouse = true;
        };
      };
      services.swayidle = let
        lock = "swaylock";
        display = status: "niri msg action power-${status}-monitors";
      in {
        enable = true;
        timeouts = [
          {
            timeout = 1800; # in seconds
            command =
              "${pkgs.libnotify}/bin/notify-send 'Locking in 5 seconds' -t 5000";
          }
          {
            timeout = 1805;
            command = lock;
          }
          {
            timeout = 1810;
            command = display "off";
            resumeCommand = display "on";
          }
          {
            timeout = 3600;
            command = "systemctl suspend";
          }
        ];
        events = [
          {
            event = "before-sleep";
            # adding duplicated entries for the same event may not work
            command = (display "off") + "; " + lock;
          }
          {
            event = "after-resume";
            command = display "on";
          }
          {
            event = "lock";
            command = (display "off") + "; " + lock;
          }
          {
            event = "unlock";
            command = display "on";
          }
        ];
      };
      services.swaync = {
        enable = true;
        style = builtins.readFile ./swaync-style.css;
        settings = builtins.readFile ./swaync-config.json;
      };
      programs.waybar.enable = true;

      xdg.configFile."waybar/config.jsonc".source = ./waybar-config.jsonc;
      xdg.configFile."waybar/style.css".source = ./waybar-style.css;

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
        platformTheme.name = "qtct";
      };

      gtk = {
        enable = true;
        theme.name = "Breeze";
        theme.package = pkgs.kdePackages.breeze-gtk;
        iconTheme = {
          name = "Papirus-Light";
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

    }];
  };
}
