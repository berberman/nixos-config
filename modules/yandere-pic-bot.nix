{ lib, inputs, config, pkgs, ... }:
let cfg = config.services.yandere-pic-bot;
in with lib; {
  options.services.yandere-pic-bot = {
    enable = mkEnableOption "Enable yandere-pic-bot";
    telegramTokenFile = mkOption {
      type = types.path;
      description = "Path to telegram token file";
    };
    dbPath = mkOption {
      type = types.path;
      description = "Path to sqlite db";
    };
    chatUsername = mkOption {
      type = types.str;
      description = "Telegram chat username";
    };
    tag = mkOption {
      type = types.str;
      description = "Tag to search";
    };

  };
  config = mkIf cfg.enable {
    systemd.services.yandere-pic-bot = let
      run = pkgs.writeShellScript "run-yandere-pic-bot" ''
        export TELEGRAM_TOKEN=$(cat ${cfg.telegramTokenFile})
        export DB_PATH=${cfg.dbPath}
        export CHAT_USERNAME=${cfg.chatUsername}
        export TAG=${cfg.tag}
        ${
          inputs.yandere-pic-bot.packages.${pkgs.system}.default
        }/bin/yandre-pic-bot
      '';
    in {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      description = "yarndere-pic-bot";
      serviceConfig = {
        ExecStart = run;
        Restart = "always";
        Type = "simple";
        StateDirectory = "yarndere-pic-bot";
      };
    };
  };
}
