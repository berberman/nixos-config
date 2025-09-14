{ lib, inputs, config, pkgs, ... }:
let cfg = config._bhome;
in with lib; {
  options._bhome = mkOption {
    type = types.attrs;
    description = "Extra home manager configuration for berberman user.";
    default = { };
  };
  config = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.berberman =
      lib.mkMerge [ { imports = [ ../desktop/home ]; } cfg ];
  };
}
