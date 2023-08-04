{ pkgs, lib, config, ... }: {
  services.znc = {
    enable = true;
    mutable = true;
    useLegacyConfig = false;
  };
  services.nginx = {
    virtualHosts."znc.typed.icu" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://127.0.0.1:1207";
    };
  };
}
