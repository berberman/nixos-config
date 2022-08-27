{ ... }: {
  imports = [ ./hardware-configuration.nix ];
  networking.hostName = "POTATO-O1";

  networking.firewall.enable = false;

  security.acme = {
    acceptTerms = true;
    defaults.email = "o1@typed.icu";
  };

  services.frps = {
    enable = true;
    config.common = {
      bind_port = 20901;
      vhost_http_port = 8080;
    };
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."nc.berberman.space" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://[::1]:8080";
    };
  };

}
