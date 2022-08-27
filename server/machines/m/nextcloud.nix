{ pkgs, lib, config, ... }: {

  services.nextcloud = {
    enable = true;
    hostName = "nc.berberman.space";
    package = pkgs.nextcloud24;
    config.adminpassFile = config.age.secrets.nextcloud-admin-password.path;
  };

  services.frpc = {
    enable = true;
    config = {
      common = {
        server_addr = "o1.typed.icu";
        server_port = 20901;
      };
      web = {
        type = "http";
        local_port = 80;
        custom_domains = "nc.berberman.space";
        host_header_rewrite = "nc.berberman.space";
      };
    };
  };

}
