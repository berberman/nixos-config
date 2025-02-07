{ global, ... }: { age.secrets = global.mkSecrets [ "github-token" ]; }
