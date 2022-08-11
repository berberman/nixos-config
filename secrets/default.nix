{ lib, ... }: {
  age.secrets = with lib;
    listToAttrs (map (n: {
      name = removeSuffix ".age" n;
      value = { file = ./. + ("/" + n); };
    }) (attrNames (import ./secrets.nix))) // {
      matrix-synapse-registration = {
        file = ./matrix-synapse-registration.age;
        owner = "matrix-synapse";
        group = "matrix-synapse";
      };
    };
}
