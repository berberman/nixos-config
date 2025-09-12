{ config, pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
    ];
  };
  time.timeZone = "Asia/Shanghai";
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = { open = false; };
}
