{ global, ... }:
{
  age.secrets = {
    matrix-synapse-registration = {
      file = global.secretFile "matrix-synapse-registration";
      owner = "matrix-synapse";
      group = "matrix-synapse";
    };
    mautrix-telegram = {
      file = global.secretFile "mautrix-telegram";
      owner = "matrix-synapse";
      group = "matrix-synapse";
    };
    grafana-secret-key = {
      file = global.secretFile "grafana-secret-key";
      owner = "grafana";
      group = "grafana";
    };
    grafana-admin-password = {
      file = global.secretFile "grafana-admin-password";
      owner = "grafana";
      group = "grafana";
    };
  }
  // global.mkSecrets [
    "wg-oa-private"
    "ircbot"
    "netbird"
  ];
}
