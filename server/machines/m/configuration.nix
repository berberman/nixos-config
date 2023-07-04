{ config, pkgs, global, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./nextcloud.nix
    ./secrets.nix
    ./minio.nix
    ./fdroid.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  services.openssh.listenAddresses = [{
    addr = "0.0.0.0";
    port = 20998;
  }];

  networking = {
    hostName = "POTATO-M";
    interfaces.ens18 = {
      ipv4.addresses = [{
        address = "10.0.1.109";
        prefixLength = 24;
      }];
      ipv6.addresses = [{
        address = "2a01:4f9:4a:286f:1:109::";
        prefixLength = 96;
      }];
    };
    defaultGateway = {
      address = "10.0.1.1";
      interface = "ens18";
    };
    defaultGateway6 = {
      address = "2a01:4f9:4a:286f:1::1";
      interface = "ens18";
    };
    nameservers =
      [ "8.8.8.8" "8.8.4.4" "2001:4860:4860::8888" "2001:4860:4860::8844" ];
  };

  networking.firewall.enable = false;

  networking.wireguard.interfaces = {
    wg0 = {
      inherit (global.wg.m) ips listenPort peers;
      privateKeyFile = global.wg.m.privateKeyFile config;
    };
  };
}
