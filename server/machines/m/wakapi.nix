{ pkgs, lib, config, ... }:
let
  user = "wakapi";
  group = "wakapi";
  home = "/var/lib/wakapi";
in {
  users.users.${user} = {
    inherit group home;
    isSystemUser = true;
    createHome = true;
  };
  users.groups.${group} = { };
  systemd.services.wakapi = let
    configFile = pkgs.writeText "wakapi-config.yml"
      ((lib.generators.toYAML { }) {
        env = "production";
        server = {
          listen_ipv4 = "10.100.0.2";
          port = 8223;
          public_url = "https://wakapi.typed.icu";
        };
        app.import_backoff_min = 1;
        mail.enabled = false;
        security.allow_signup = false;
        security.password_salt = "x49CoTWPyhoXXfHWRjSISM5lQKkL7xEd";
      });
  in {

    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    startLimitBurst = 3;
    startLimitIntervalSec = 400;

    serviceConfig = {
      User = user;
      Group = group;
      ExecStart = "${pkgs.wakapi}/bin/wakapi -config ${configFile}";
      Restart = "on-failure";
      RestartSec = "90";
      WorkingDirectory = home;
      # Security hardening
      PrivateTmp = "true";
      PrivateUsers = "true";
      NoNewPrivileges = "true";
      ProtectSystem = "full";
      ProtectHome = "true";
      ProtectKernelTunables = "true";
      ProtectKernelModules = "true";
      ProtectKernelLogs = "true";
      ProtectControlGroups = "true";
      PrivateDevices = "true";
      CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
      ProtectClock = "true";
      RestrictSUIDSGID = "true";
      ProtectHostname = "true";
      ProtectProc = "invisible";
    };
  };
}
