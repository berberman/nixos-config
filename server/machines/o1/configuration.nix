{ pkgs, config, global, ... }: {
  imports = [ ./hardware-configuration.nix ./secrets.nix ];

  networking.hostName = "POTATO-O1";

  networking.firewall.enable = false;
  networking.nat.enable = true;
  networking.nat.externalInterface = "ens3";
  networking.nat.internalInterfaces = [ "wg0" ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "o1@typed.icu";
  };

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.100.0.1/24" ];
      listenPort = 20988;
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o ens3 -j MASQUERADE
      '';
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o ens3 -j MASQUERADE
      '';

      privateKeyFile = config.age.secrets.wg-o1-private.path;

      peers = [{
        publicKey = global.wg.public.m;
        allowedIPs = [ "10.100.0.2/32" ];
      }];
    };
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."nc.berberman.space" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://10.100.0.2";
    };
  };

}
