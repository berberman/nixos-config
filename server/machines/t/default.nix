{ pkgs, config, global, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./secrets.nix
    ./fdroid.nix
    ./vaultwarden.nix
    ./wakapi.nix
  ];

  networking.hostName = "POTATO-T";

  networking.firewall.allowedTCPPorts = [ 443 80 22 8008 8222 8223 ];
  networking.firewall.allowedUDPPorts = [ 20998 ];

  users.users.jacky = {
    isNormalUser = true;
    shell = pkgs.zsh;
    home = "/home/jacky";
  };

  boot.loader = {
    grub = {
      enable = true;
      device = "/dev/sda";
    };
  };

  networking = {

    wireguard.interfaces = {
      wg0 = {
        inherit (global.wg.t) ips listenPort peers;
        privateKeyFile = global.wg.t.privateKeyFile config;
        postSetup = ''
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o ens18 -j MASQUERADE
        '';
        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o ens18 -j MASQUERADE
        '';
      };
    };

    interfaces.ens18 = {
      ipv6.addresses = [{
        address = "2602:fc52:1ff:e::109";
        prefixLength = 64;
      }];
    };

    defaultGateway6 = {
      address = "2602:fc52:1ff::1";
      interface = "ens18";
    };

    nameservers = [ "2606:4700:4700::1001" "2606:4700:4700::1111" ];

  };

  system.stateVersion = "25.05";

}
