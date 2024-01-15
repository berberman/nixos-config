{ pkgs, lib, config, ... }: {
  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://bitwarden.torus.icu";
      SIGNUPS_ALLOWED = false;
      ROCKET_ADDRESS = "10.100.0.2";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "critical";
    };
    environmentFile = config.age.secrets.vaultwarden.path;
  };
}
