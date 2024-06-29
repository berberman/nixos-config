{ config, pkgs, ... }:

{
  services.automatic-timezoned.enable = true;
  hardware.bluetooth.enable = true;
  environment.systemPackages = with pkgs; [ mathematica ];
}
