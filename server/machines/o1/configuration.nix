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

  services.frps = {
    enable = true;
    config = { common = { bind_port = 7654; }; };
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
    virtualHosts."nc.typed.icu" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://10.100.0.2";
    };
    virtualHosts."s3.typed.icu" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = { proxyPass = "http://10.100.0.2:9000"; };
      extraConfig = ''
        client_max_body_size 0;
        proxy_buffering off;
        proxy_request_buffering off;
        ignore_invalid_headers off;
        chunked_transfer_encoding off;
      '';
    };
    virtualHosts."s3c.typed.icu" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://10.100.0.2:9001";
        proxyWebsockets = true;
      };
    };
  };

}
