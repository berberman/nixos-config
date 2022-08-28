{ global, ... }: { age.secrets = global.mkSecrets [ "wg-o1-private" ]; }
