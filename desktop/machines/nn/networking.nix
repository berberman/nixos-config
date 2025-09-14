{ config, pkgs, ... }:

let myProxy = "http://192.168.31.88:8888";
in {
  systemd.services.NetworkManager-wait-online.enable = false;
  networking = {
    hostName = "POTATO-NN";
    useDHCP = false;
    networkmanager.enable = true;
    proxy = {
      default = myProxy;
      noProxy = "127.0.0.1,localhost,internal.domain";
    };
    firewall.enable = false;
  };

  systemd.services.nix-daemon.environment = {
    HTTP_PROXY = myProxy;
    HTTPS_PROXY = myProxy;
    http_proxy = myProxy;
    https_proxy = myProxy;
  };
  _bhome = { pkgs, ... }: {
    # proxychains config
    home.file.".proxychains/proxychains.conf".text = ''
      strict_chain

      proxy_dns 

      remote_dns_subnet 224

      tcp_read_time_out 15000
      tcp_connect_time_out 8000

      localnet 127.0.0.0/255.0.0.0

      [ProxyList]
      socks5 192.168.31.88 1080
    '';
    home.packages = with pkgs; [ proxychains ];
  };
}
