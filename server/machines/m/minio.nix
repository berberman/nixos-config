{ pkgs, lib, config, ... }: {
  services.minio = {
    enable = true;
    region = "eu-central-1";
    rootCredentialsFile = config.age.secrets.minio-credentials.path;
  };
}
