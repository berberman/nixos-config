{ config, pkgs, global, ... }:

{
  systemd.services.NetworkManager-wait-online.enable = false;
  networking = {
    hostName = "POTATO-NR";
    useDHCP = false;
    networkmanager.enable = true;
    firewall.enable = false;
    wg-quick.interfaces = {
      wg0 = {
        address = global.wg.nr.ips;
        privateKeyFile = global.wg.nr.privateKeyFile config;
        inherit (global.wg.nr) listenPort peers;
        dns = [ "1.1.1.1" ];
        postUp = ''
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o enp6s0 -j MASQUERADE
        '';
        preDown = ''
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o enp6s0 -j MASQUERADE
        '';
      };
      # wgcf = {
      #   address =
      #     [ "172.16.0.2/32" "2606:4700:110:8902:c9ad:455d:cf3b:52f8/128" ];
      #   dns = [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
      #   privateKeyFile = config.age.secrets.wgcf.path;
      #   mtu = 1280;
      #   peers = [{
      #     publicKey = "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=";
      #     allowedIPs = [ "0.0.0.0/0" "::/0" ];
      #     endpoint = "engage.cloudflareclient.com:2408";
      #   }];
      # };
    };
  };
}
