{ global, ... }: {
  age.secrets = {
    matrix-synapse-registration = {
      file = global.secretFile "matrix-synapse-registration";
      owner = "matrix-synapse";
      group = "matrix-synapse";
    };
  } // global.mkSecrets [
    "wg-oa-private"
    "ircbot"
  ];
}
