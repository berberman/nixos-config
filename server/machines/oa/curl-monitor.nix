{
  config,
  lib,
  pkgs,
  ...
}:

let
  curlTargets0 = {
    sso = "https://sso.torus.icu/-/health/live/";
    wakapi = "https://wakapi.torus.icu/api/health";
    vaultwarden = "https://bitwarden.torus.icu/alive";
    coder = "https://coder.jackywang.page/healthz";
    pve-webui-union1 = "https://union1.jackywang.page:8006";
    pve-webui-union2 = "https://union2.jackywang.page:8006";
    pve-webui-union3 = "https://union3.jackywang.page:8006";
  };

  curlTargets =
    with lib;
    concatMapAttrs (name: url: {
      "${name}-auto" = {
        url = url;
        curlArgs = [ ];
      };
      "${name}-ipv4" = {
        url = url;
        curlArgs = [ "--ipv4" ];
      };
      "${name}-ipv6" = {
        url = url;
        curlArgs = [ "--ipv6" ];
      };
    }) curlTargets0;

  curlWriteOut = pkgs.writeText "curl-probe-writeout.json" ''
    %{stderr}{"event":"curl_summary","curl":%{json},"response_headers":%{header_json}}
  '';

  mkCurlProbe = name: target: {
    description = "Verbose external HTTP probe for ${name}";

    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    unitConfig = {
      StartLimitIntervalSec = 0;
    };

    serviceConfig = {
      Type = "oneshot";

      StandardOutput = "journal";
      StandardError = "journal";
      SyslogIdentifier = "curl-verbose-probe";

      DynamicUser = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";

      ExecStart = lib.concatStringsSep " " (
        [
          "${pkgs.curl}/bin/curl"
          "--silent"
          "--show-error"
          "--verbose"
          "--trace-time"
          "--trace-ids"
          "--fail"
          "--output"
          "/dev/null"
          "--connect-timeout"
          "2"
          "--max-time"
          "5"
          "--user-agent"
          "external-forensic-probe/1.0"
          "--write-out"
          "@${curlWriteOut}"
        ]
        ++ target.curlArgs
        ++ [ target.url ]
      );
    };
  };

  mkCurlTimer = name: {
    description = "Schedule verbose external HTTP probe for ${name}";

    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnBootSec = "20s";
      OnUnitInactiveSec = "2s";
      AccuracySec = "100ms";
      RandomizedDelaySec = "0";
      Unit = "curl-verbose-${name}.service";
    };
  };
in
{
  systemd.services = lib.mapAttrs' (
    name: target: lib.nameValuePair "curl-verbose-${name}" (mkCurlProbe name target)
  ) curlTargets;

  systemd.timers = lib.mapAttrs' (
    name: _: lib.nameValuePair "curl-verbose-${name}" (mkCurlTimer name)
  ) curlTargets;

  services.journald.extraConfig = ''
    Storage=persistent
    SystemMaxUse=1G
    MaxRetentionSec=72h
  '';
}
