let keys = (import ../global.nix).pubKeys;
in {
  "matrix-synapse-registration.age".publicKeys = keys;
  "nextcloud-admin-password.age".publicKeys = keys;
  "wg-o1-private.age".publicKeys = keys;
  "wg-m-private.age".publicKeys = keys;
  "wg-o0-private.age".publicKeys = keys;
  "wg-oa-private.age".publicKeys = keys;
  "wg-nr-private.age".publicKeys = keys;
  "minio-credentials.age".publicKeys = keys;
  "wgcf.age".publicKeys = keys;
  "telegram-token.age".publicKeys = keys;
  "v2o0.age".publicKeys = keys;
  "v2o0c.age".publicKeys = keys;
  "vaultwarden.age".publicKeys = keys;
  "ircbot.age".publicKeys = keys;
  "github-token.age".publicKeys = keys;
  "mautrix-telegram.age".publicKeys = keys;
}
