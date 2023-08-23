{ config, pkgs, ... }: {
  services.transmission = {
    enable = true;
    settings = {
      rpc-bind-address = "0.0.0.0";
      peer-port = 20901;
      rpc-whitelist-enabled = false;
      rpc-authentication-required = true;
      rpc-port = 20902;
      rpc-username = "root";
      rpc-password = "{a4d3e47a3ecfe766c78e2071deb382c34b5945877.W7wcar";
    };
  };
  systemd.services.transmission.serviceConfig.NetworkNamespacePath =
    "/run/netns/lu";
}
