{ config, pkgs, ... }:

{
  time.timeZone = "America/Los_Angeles";
  hardware.bluetooth.enable = true;
  virtualisation.docker.enable = true;
  environment.systemPackages = with pkgs; [ mathematica ];
  services.xserver.videoDrivers = [ "nvidia" ];
  virtualisation.virtualbox.host.enableExtensionPack = true;
  virtualisation.virtualbox.host.enable = true;
  hardware.nvidia = { open = true; };
  niriExtra = ''
    output "Dell Inc. DELL S2721QS 41CMM43" {
        scale 2
        focus-at-startup
        position x=-1080 y=400
    }
    output "PNP(AOC) U2790B 0x000032FA" {
        scale 2
        transform "270"
    }
  '';
}
