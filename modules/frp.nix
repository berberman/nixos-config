{ ... }:
let
  mkModule = name:
    { pkgs, config, lib, ... }:
    with lib;
    let
      cfg = config.services.${name};
      configFile =
        pkgs.writeText "${name}.ini" (generators.toINI { } cfg.config);
    in {
      options.services.${name} = {
        enable = mkEnableOption "Enable ${name}";
        config = mkOption {
          type = with types; attrsOf (attrsOf (oneOf [ str bool int ]));
          description = "${name} config file (ini)";
          default = { };
        };
      };
      config = mkIf cfg.enable {
        systemd.services.${name} = {
          description = "${name} service";
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            ExecStart = "${pkgs.frp}/bin/${name} -c ${configFile}";
            Restart = "always";
            RestartSec = "5s";
            Type = "simple";
          };
        };
      };
    };
in { imports = builtins.map mkModule [ "frpc" "frps" ]; }
