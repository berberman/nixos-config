{ lib, inputs, config, pkgs, ... }:
let cfg = config.services.ircbot;
in with lib; {
  options.services.ircbot = {
    enable = mkEnableOption "Enable ircbot";
    environmentFile = mkOption {
      type = types.str;
      description = "Environment file for ircbot";
    };
  };
  config = mkIf cfg.enable {
    systemd.services.ircbot = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      description = "ircbot";
      serviceConfig = {
        EnvironmentFile = cfg.environmentFile;
        ExecStart =
          "${inputs.ircbot.packages.${pkgs.system}.default}/bin/ircbot";
        Restart = "always";
        RestartSec = "5s";
        Type = "simple";
      };
    };
  };
}
