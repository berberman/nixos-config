{ pkgs, config, global, ... }: {
  imports = [ ./hardware-configuration.nix ./secrets.nix ./matrix.nix ];

  networking.hostName = "POTATO-OA";
  networking.firewall.enable = false;
  networking.interfaces.ens3.useDHCP = true;
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "acme@typed.icu";
  boot.zfs.devNodes = "/dev";
  networking.hostId = "c271c48d";
}
