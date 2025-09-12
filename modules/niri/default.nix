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
    environment.systemPackages = (with pkgs; [
      wl-clipboard
      wayland-utils
      xwayland-satellite
      grim
      slurp
      swww
      waypaper
    ]) ++ (with pkgs.kdePackages; [
      dolphin
      ark
      gwenview
      okular
      kate
      kgpg
      kdeconnect-kde
      konsole
    ]);
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
    };
  };
}
