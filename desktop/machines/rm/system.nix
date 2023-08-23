{ config, pkgs, ... }:

{
  time.timeZone = "America/New_York";
  hardware.bluetooth.enable = true;
  environment.systemPackages = with pkgs; [ mathematica ];
}
