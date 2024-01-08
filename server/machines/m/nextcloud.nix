{ pkgs, lib, config, ... }: {

  services.nextcloud = {
    enable = false;
    hostName = "nc.torus.icu";
    package = pkgs.nextcloud27;
    config.adminpassFile = config.age.secrets.nextcloud-admin-password.path;
    enableBrokenCiphersForSSE = false;
  };

}
