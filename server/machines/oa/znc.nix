{ pkgs, lib, config, ... }: {
  services.znc = {
    enable = true;
    mutable = true;
    useLegacyConfig = false;
  };
  services.nginx = {
    virtualHosts."znc.torus.icu" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://127.0.0.1:1207";
    };
    streamConfig = ''
     upstream znc {
          server 127.0.0.1:1207;
      }
      server {
           listen                  1206 ssl;
           ssl_certificate         /var/lib/acme/znc.torus.icu/fullchain.pem;
           ssl_certificate_key     /var/lib/acme/znc.torus.icu/key.pem;
           ssl_trusted_certificate /var/lib/acme/znc.torus.icu/chain.pem;
           
           proxy_pass znc;
       } 
    '';
  };
}
