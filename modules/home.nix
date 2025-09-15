{ lib, inputs, config, pkgs, ... }:
let cfg = config._bhome;
in with lib; {
  options._bhome = {
    enable = lib.mkEnableOption
      "Enable extra home manager configuration for berberman user.";
    imports = mkOption {
      type = types.listOf types.anything;
      description =
        "Import list of home manager configuration for berberman user.";
      default = [ ];
    };
  };
  config = lib.mkIf cfg.enable {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.berberman = {
      imports = [ ../desktop/home ] ++ cfg.imports;
    };
  };
}
