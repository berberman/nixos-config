{ global, ... }: {
  age.secrets = global.mkSecrets [
    "wgcf"
    "wg-nr-private"
  ];
}
