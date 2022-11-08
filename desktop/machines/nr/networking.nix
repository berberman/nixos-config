{ config, pkgs, ... }:

{
  systemd.services.NetworkManager-wait-online.enable = false;
  networking = {
    hostName = "POTATO-NR";
    useDHCP = false;
    networkmanager.enable = true;
    firewall.enable = false;
    wg-quick.interfaces = {
      wgcf = {
        address =
          [ "172.16.0.2/32" "fd01:5ca1:ab1e:8962:bfd4:20b5:bf0c:f259/128" ];
        dns = [ "1.1.1.1" ];
        privateKeyFile = "/home/berberman/.wgcf/a.key";
        mtu = 1280;
        peers = [{
          publicKey = "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=";
          allowedIPs = [ "0.0.0.0/0" "::/0" ];
          endpoint = "162.159.192.1:2408";
        }];
      };
    };
  };
}
