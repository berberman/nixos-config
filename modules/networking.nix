{ config, pkgs, ... }:

let myProxy = "http://192.168.31.88:8888";
in {

  networking = {
    hostName = "POTATO-NN";
    useDHCP = false;
    networkmanager.enable = true;
    proxy = {
      default = myProxy;
      noProxy = "127.0.0.1,localhost,internal.domain";
    };
  };

  systemd.services.nix-daemon.environment = {
    HTTP_PROXY = myProxy;
    HTTPS_PROXY = myProxy;
    http_proxy = myProxy;
    https_proxy = myProxy;
  };

}
