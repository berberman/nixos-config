{ lib, ... }: {
  age.secrets = with lib;
    listToAttrs (map (n: {
      name = removeSuffix ".age" n;
      value = { file = ./. + ("/" + n); };
    }) (attrNames (import ./secrets.nix)));
}
