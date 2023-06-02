{ pkgs, lib, config, ... }: {

  services.nextcloud = {
    enable = true;
    hostName = "nc.typed.icu";
    package = pkgs.nextcloud26;
    config.adminpassFile = config.age.secrets.nextcloud-admin-password.path;
    enableBrokenCiphersForSSE = false;
  };

}
