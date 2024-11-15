{ inputs, config, pkgs, ... }: {
  imports = [ "${inputs.vscode-server}/modules/vscode-server/home.nix" ];

  systemd.user.services.vscode-tunnel = {
    Unit = {
      Description = "Visual Studio Code Tunnel";
      After = [ "network.target" ];
      StartLimitIntervalSec = 0;
    };
    Service = {
      Type = "simple";
      Restart = "always";
      RestartSec = 10;
      Environment = "PATH=${
          builtins.concatStringsSep ":" [
            "/run/wrappers/bin"
            "/run/current-system/sw/bin"
            "${config.home.profileDirectory}/bin"
          ]
        }";
      ExecStart = ''
        "${pkgs.vscode}/bin/code" tunnel service internal-run --cli-data-dir %h/.vscode-server 
      '';
    };
    Install.WantedBy = [ "default.target" ];
  };

  programs.vscode.enable = true;

  services.vscode-server.enable = true;

  home.stateVersion = "24.05";
}
