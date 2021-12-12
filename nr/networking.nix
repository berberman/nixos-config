{ config, pkgs, ... }:

{
  networking = {
    hostName = "POTATO-NR";
    useDHCP = false;
    networkmanager.enable = true;
    firewall.enable = false;
  };
}
