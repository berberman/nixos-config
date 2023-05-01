{ pkgs, config, global, ... }: {
  services.headscale = {
    enable = true;
    address = "127.0.0.1";
    port = 8686;
    settings = {
      server_url = "https://tailscale.typed.icu";
      dns_config = { baseDomain = "ts.typed.icu"; };
      logtail = { enabled = false; };
      ip_prefixes = [ "100.64.0.0/10" "fdaf:3a5e:a286::/48" ];
    };
  };
  environment.systemPackages = [ config.services.headscale.package ];
  services.nginx.virtualHosts."tailscale.typed.icu" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.headscale.port}";
      proxyWebsockets = true;
    };
  };
}
