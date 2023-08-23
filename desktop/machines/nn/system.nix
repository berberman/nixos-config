{ config, pkgs, ... }:

{
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [ vaapiIntel vaapiVdpau libvdpau-va-gl ];
  };
  time.timeZone = "Asia/Shanghai";
  services.xserver.videoDrivers = [ "nvidia" ];
}
