{ pkgs, config, global, ... }: {
  services.headscale = {
    enable = true;
    address = "127.0.0.1";
    port = 8686;
    settings = {
      server_url = "https://tailscale.torus.icu";
      dns_config = {
        magic_dns = true;
        nameservers = [ "1.1.1.1" ];
        baseDomain = "torus.icu";
      };
      logtail = { enabled = false; };
      ip_prefixes = [ "100.64.0.0/10" "fd7a:115c:a1e0::/48" ];
      derp.server = {
        enable = true;
        region_id = 999;
        stun_listen_addr = "0.0.0.0:3478";
      };
    };
  };
  environment.systemPackages = [ config.services.headscale.package ];
  services.nginx.virtualHosts."tailscale.torus.icu" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.headscale.port}";
      proxyWebsockets = true;
    };
  };
}
