let keys = (import ../global.nix).pubKeys;
in {
  "pixiv-token.age".publicKeys = keys;
  "google-key.age".publicKeys = keys;
  "google-cx.age".publicKeys = keys;
  "telegraph-token.age".publicKeys = keys;
  "matrix-synapse-registration.age".publicKeys = keys;
}
