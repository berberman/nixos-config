{ pkgs, config, global, ... }: {
  imports = [ ./hardware-configuration.nix ./secrets.nix ./headscale.nix ];

  networking.hostName = "POTATO-O1";

  networking.firewall.enable = false;

  security.acme = {
    acceptTerms = true;
    defaults.email = "o1@torus.icu";
  };

  # services.frps = {
  #   enable = true;
  #   config = { common = { bind_port = 7654; }; };
  # };

  networking.wireguard.interfaces = {
    wg0 = {
      inherit (global.wg.o1) ips listenPort peers;
      privateKeyFile = global.wg.o1.privateKeyFile config;
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o ens3 -j MASQUERADE
      '';
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o ens3 -j MASQUERADE
      '';
    };
  };

  services.yandere-pic-bot = {
    enable = true;
    telegramTokenFile = config.age.secrets.telegram-token.path;
    dbPath = "/var/lib/yandere-pic-bot/db.sqlite";
    chatUsername = "@azuuru_pics";
    tag = "azuuru";
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    # virtualHosts."nc.torus.icu" = {
    #   enableACME = true;
    #   forceSSL = true;
    #   locations."/".proxyPass = "http://10.100.0.2";
    # };
    virtualHosts."o1.torus.icu" = {
      enableACME = true;
      forceSSL = true;
      default = true;
      locations."/".return = "302 https://torus.icu";
    };
    # virtualHosts."s3.torus.icu" = {
    #   enableACME = true;
    #   forceSSL = true;
    #   locations."/" = { proxyPass = "http://10.100.0.2:9000"; };
    #   extraConfig = ''
    #     client_max_body_size 0;
    #     proxy_buffering off;
    #     proxy_request_buffering off;
    #     ignore_invalid_headers off;
    #     chunked_transfer_encoding off;
    #   '';
    # };
    # virtualHosts."s3c.torus.icu" = {
    #   enableACME = true;
    #   forceSSL = true;
    #   locations."/" = {
    #     proxyPass = "http://10.100.0.2:9001";
    #     proxyWebsockets = true;
    #   };
    # };
    virtualHosts."f5a.torus.icu" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://10.100.0.6:8008";
        extraConfig = ''
          proxy_redirect http://f5a.torus.icu:8008/ http://f5a.torus.icu/;
        '';
      };
    };
    virtualHosts."netdata.torus.icu" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = { proxyPass = "http://127.0.0.1:8009"; };
    };
    virtualHosts."bitwarden.torus.icu" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = { proxyPass = "http://10.100.0.6:8222"; };
    };
    virtualHosts."wakapi.torus.icu" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = { proxyPass = "http://10.100.0.6:8223"; };
    };
  };

  services.netdata-child.enable = false;
  services.netdata-parent = {
    enable = true;
    apiKey = global.netdataApiKey;
    allowFrom = "10.*";
  };
  services.netdata.config.web."bind to" =
    "127.0.0.1:8009=dashboard 10.100.0.1:19999=streaming";
  system.stateVersion = "22.05";
}
