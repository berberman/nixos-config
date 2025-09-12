{ lib, inputs, config, pkgs, ... }:
let cfg = config.bhome;
in with lib; {
  options.bhome = mkOption {
    type = types.attrs;
    description = "Extra home manager configuration for berberman user.";
    default = { };
  };
  config = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.berberman = { imports = [ ../desktop/home ]; } // cfg;
  };
}
