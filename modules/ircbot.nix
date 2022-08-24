{ lib, inputs, config, pkgs, ... }:
let cfg = config.services.ircbot;
in with lib; {
  options.services.ircbot = {
    enable = mkEnableOption "Enable ircbot";
    nick = mkOption {
      type = types.str;
      description = "irc nickname";
    };
    username = mkOption {
      type = types.str;
      description = "irc username";
      default = cfg.nick;
    };
    realname = mkOption {
      type = types.str;
      description = "irc realname";
      default = cfg.nick;
    };
    passwordFile = mkOption {
      type = types.path;
      description = "irc password";
    };
    channels = mkOption {
      type = types.listOf types.str;
      description = "irc channels to join";
    };
    pixivTokenFile = mkOption {
      type = types.path;
      description = "Path to pixiv token file";
    };
    googleKeyFile = mkOption {
      type = types.path;
      description = "Path to google key file";
    };
    googleCxFile = mkOption {
      type = types.path;
      description = "Path to google cx file";
    };
    telegraphTokenFile = mkOption {
      type = types.path;
      description = "Path to telegraph token file";
    };
  };
  config = mkIf cfg.enable {
    systemd.services.ircbot = let
      run = pkgs.writeShellScript "run-ircbot" ''
        export NICK=${cfg.nick}
        export USERNAME=${cfg.username}
        export REALNAME=${cfg.realname}
        export CHANNELS=${concatStringsSep "," cfg.channels}
        export PASSWORD=$(cat ${cfg.passwordFile})
        export PIXIV_TOKEN=$(cat ${cfg.pixivTokenFile})
        export GOOGLE_KEY=$(cat ${cfg.googleKeyFile})
        export GOOGLE_CX=$(cat ${cfg.googleCxFile})
        export TELEGRAPH_TOKEN=$(cat ${cfg.telegraphTokenFile})
        ${inputs.ircbot.packages.${pkgs.system}.default}/bin/ircbot
      '';
    in {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      description = "ircbot";
      serviceConfig = {
        ExecStart = run;
        Restart = "always";
        RestartSec = "1s";
        Type = "simple";
      };
    };
  };
}
