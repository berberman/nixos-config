{ config, pkgs, ... }:

{
  time.timeZone = "America/New_York";
  hardware.bluetooth.enable = true;
  virtualisation.docker.enable = true;
  environment.systemPackages = with pkgs; [ mathematica ];
  services.xserver.videoDrivers = [ "nvidia" ];
}
