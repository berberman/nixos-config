{ config, pkgs, global, ... }:

{
  systemd.services.NetworkManager-wait-online.enable = false;
  networking = {
    hostName = "POTATO-RM";
    useDHCP = false;
    networkmanager.enable = true;
    firewall.enable = false;
  };
  services.resolved.enable = true;
}
