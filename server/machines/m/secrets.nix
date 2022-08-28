{ global, ... }: {
  age.secrets = {
    nextcloud-admin-password = {
      file = global.secretFile "nextcloud-admin-password";
      owner = "nextcloud";
      group = "nextcloud";
    };
  } // global.mkSecrets [ "wg-m-private" ];
}
