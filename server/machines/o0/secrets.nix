{ global, ... }: {
  age.secrets = global.mkSecrets [
    "google-cx"
    "google-key"
    "pixiv-token"
    "telegraph-token"
    "wg-o0-private"
  ];
}
