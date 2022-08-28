{ pkgs, lib, config, ... }: {

  services.nextcloud = {
    enable = true;
    hostName = "nc.berberman.space";
    package = pkgs.nextcloud24;
    config.adminpassFile = config.age.secrets.nextcloud-admin-password.path;
  };

}
