{ global, ... }: {
  age.secrets = {
    vaultwarden = {
      file = global.secretFile "vaultwarden";
      owner = "vaultwarden";
      group = "vaultwarden";
    };
  } // global.mkSecrets [ "wg-t-private" ];
}
