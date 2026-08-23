{ global, ... }: {
  age.secrets = global.mkSecrets [ "wg-t-private" ];
}
