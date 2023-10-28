{ config, pkgs, ... }: {
  services.transmission = {
    enable = true;
    settings = {
      rpc-bind-address = "10.0.9.1";
      peer-port = 20901;
      rpc-whitelist-enabled = false;
      rpc-authentication-required = true;
      rpc-port = 7878;
      rpc-username = "root";
      rpc-password = "{a4d3e47a3ecfe766c78e2071deb382c34b5945877.W7wcar";
    };
  };
  systemd.services.transmission.serviceConfig.NetworkNamespacePath =
    "/run/netns/lu";
  services.nginx.enable = true;
  services.nginx.virtualHosts."transmission" = {
    listen = [{
      addr = "0.0.0.0";
      port = 7878;
    }];
    locations."/" = {
      proxyPass = "http://10.0.9.1:7878";
      recommendedProxySettings = true;
      extraConfig = ''
        proxy_pass_header X-Transmission-Session-Id;
      '';
    };

  };
}
