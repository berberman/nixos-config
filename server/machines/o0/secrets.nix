{ global, ... }: {
  age.secrets = {
    v2o0c = {
      file = global.secretFile "v2o0c";
      owner = "caddy";
      group = "caddy";
    };
    v2o0 = {
      file = global.secretFile "v2o0";
      mode = "744";
    };
  } // global.mkSecrets [ "wg-o0-private" ];
}
