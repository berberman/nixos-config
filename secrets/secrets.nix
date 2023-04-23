let keys = (import ../global.nix).pubKeys;
in {
  "pixiv-token.age".publicKeys = keys;
  "google-key.age".publicKeys = keys;
  "google-cx.age".publicKeys = keys;
  "telegraph-token.age".publicKeys = keys;
  "matrix-synapse-registration.age".publicKeys = keys;
  "nextcloud-admin-password.age".publicKeys = keys;
  "wg-o1-private.age".publicKeys = keys;
  "wg-m-private.age".publicKeys = keys;
  "wg-o0-private.age".publicKeys = keys;
  "wg-oa-private.age".publicKeys = keys;
  "wg-nr-private.age".publicKeys = keys;
  "minio-credentials.age".publicKeys = keys;
  "wgcf.age".publicKeys = keys;
}
