{ global, ... }: {
  age.secrets = {
    nextcloud-admin-password = {
      file = global.secretFile "nextcloud-admin-password";
      owner = "nextcloud";
      group = "nextcloud";
    };
    minio-credentials = {
      file = global.secretFile "minio-credentials";
      owner = "minio";
      group = "minio";
    };
  } // global.mkSecrets [ "wg-m-private" ];
}
