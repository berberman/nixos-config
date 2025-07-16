{ lib, config, pkgs, ... }:
let
  parentCfg = config.services.netdata-parent;
  childCfg = config.services.netdata-child;
in with lib; {
  options.services.netdata-parent = {
    enable = lib.mkEnableOption "Enable netdata parent";
    apiKey = mkOption {
      type = types.str;
      description = "The API_KEY to use as the child node";
    };
    allowFrom = mkOption {
      type = types.str;
      default = "*";
      description = "IPs of nodes that will stream metrics using this API key";
    };
  };
  options.services.netdata-child = {
    enable = mkEnableOption "Enable netdata child";
    dest = mkOption {
      type = types.str;
      description = "Parent node to attempt to stream to";
    };
    apiKey = mkOption {
      type = types.str;
      description = "The API_KEY to use as the child node";
    };
  };

  config = mkMerge [
    (mkIf parentCfg.enable {
      services.netdata = {
        enable = true;
        package = pkgs.netdata.override { withCloudUi = true; };
        config = { ml.enabled = "yes"; };
        configDir = {
          "stream.conf" = pkgs.writeText "stream.conf" ''
            [${parentCfg.apiKey}]
              enabled = yes
              default memory mode = dbengine
              allow from = ${parentCfg.allowFrom}
          '';
        };
      };
    })
    (mkIf childCfg.enable {
      services.netdata = {
        enable = true;
        config = {
          global = { "default memory mode" = "none"; };
          ml.enabled = "yes";
          web.mode = "none";
        };
        configDir = {
          "stream.conf" = pkgs.writeText "stream.conf" ''
            [stream]
              enabled = yes
              destination = ${childCfg.dest}
              api key = ${childCfg.apiKey}
          '';
        };
      };
    })
  ];
}
