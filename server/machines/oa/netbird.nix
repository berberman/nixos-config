# Auto-generated using compose2nix v0.3.3-pre.
{ pkgs, lib, config, ... }:

{

  services.nginx = {
    virtualHosts = {
      "netbird.torus.icu" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:8011";
            proxyWebsockets = true;
          };
          "/relay" = {
            proxyPass = "http://127.0.0.1:33080";
            proxyWebsockets = true;
          };
          "/signalexchange.SignalExchange/".extraConfig = ''
            # This is necessary so that grpc connections do not get closed early
            # see https://stackoverflow.com/a/67805465
            client_body_timeout 1d;

            grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            grpc_pass grpc://localhost:10000;
            grpc_read_timeout 1d;
            grpc_send_timeout 1d;
            grpc_socket_keepalive on;
          '';
          "/api".proxyPass = "http://localhost:33073";
          "/management.ManagementService/".extraConfig = ''
            # This is necessary so that grpc connections do not get closed early
            # see https://stackoverflow.com/a/67805465
            client_body_timeout 1d;

            grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            grpc_pass grpc://localhost:33073;
            grpc_read_timeout 1d;
            grpc_send_timeout 1d;
            grpc_socket_keepalive on;
          '';
        };
      };
    };
  };

  # Containers
  virtualisation.oci-containers.containers."netbird-coturn" = {
    image = "coturn/coturn:latest";
    volumes = [ "/var/lib/netbird/turnserver.conf:/etc/turnserver.conf:ro" ];
    cmd = [ "-c /etc/turnserver.conf" ];
    log-driver = "journald";
    extraOptions = [ "--network=host" ];
  };
  systemd.services."podman-netbird-coturn" = {
    serviceConfig = { Restart = lib.mkOverride 90 "always"; };
    partOf = [ "podman-compose-netbird-root.target" ];
    wantedBy = [ "podman-compose-netbird-root.target" ];
  };
  virtualisation.oci-containers.containers."netbird-dashboard" = {
    image = "netbirdio/dashboard:latest";
    environmentFiles = [ "/run/agenix/netbird" ];

    ports = [ "8011:80/tcp" ];
    log-driver = "journald";
    extraOptions = [ "--network-alias=dashboard" "--network=netbird_default" ];
  };
  systemd.services."podman-netbird-dashboard" = {
    serviceConfig = { Restart = lib.mkOverride 90 "always"; };
    after = [ "podman-network-netbird_default.service" ];
    requires = [ "podman-network-netbird_default.service" ];
    partOf = [ "podman-compose-netbird-root.target" ];
    wantedBy = [ "podman-compose-netbird-root.target" ];
  };
  virtualisation.oci-containers.containers."netbird-management" = {
    image = "netbirdio/management:latest";
    environmentFiles = [ "/run/agenix/netbird" ];
    volumes = [
      "/var/lib/netbird/management.json:/etc/netbird/management.json:rw"
      "netbird_netbird-mgmt:/var/lib/netbird:rw"
    ];
    ports = [ "33073:443/tcp" ];
    cmd = [
      "--port"
      "443"
      "--log-file"
      "console"
      "--log-level"
      "debug"
      "--disable-anonymous-metrics=false"
      "--single-account-mode-domain=netbird.torus.icu"
      "--dns-domain=netbird.selfhosted"
    ];
    dependsOn = [ "netbird-dashboard" ];
    log-driver = "journald";
    extraOptions = [ "--network-alias=management" "--network=netbird_default" ];
  };
  systemd.services."podman-netbird-management" = {
    serviceConfig = { Restart = lib.mkOverride 90 "always"; };
    after = [
      "podman-network-netbird_default.service"
      "podman-volume-netbird_netbird-mgmt.service"
    ];
    requires = [
      "podman-network-netbird_default.service"
      "podman-volume-netbird_netbird-mgmt.service"
    ];
    partOf = [ "podman-compose-netbird-root.target" ];
    wantedBy = [ "podman-compose-netbird-root.target" ];
  };
  virtualisation.oci-containers.containers."netbird-relay" = {
    image = "netbirdio/relay:latest";
    environmentFiles = [ "/run/agenix/netbird" ];

    ports = [ "33080:33080/tcp" ];
    log-driver = "journald";
    extraOptions = [ "--network-alias=relay" "--network=netbird_default" ];
  };
  systemd.services."podman-netbird-relay" = {
    serviceConfig = { Restart = lib.mkOverride 90 "always"; };
    after = [ "podman-network-netbird_default.service" ];
    requires = [ "podman-network-netbird_default.service" ];
    partOf = [ "podman-compose-netbird-root.target" ];
    wantedBy = [ "podman-compose-netbird-root.target" ];
  };
  virtualisation.oci-containers.containers."netbird-signal" = {
    image = "netbirdio/signal:latest";
    volumes = [ "netbird_netbird-signal:/var/lib/netbird:rw" ];
    ports = [ "10000:80/tcp" ];
    log-driver = "journald";
    extraOptions = [ "--network-alias=signal" "--network=netbird_default" ];
  };
  systemd.services."podman-netbird-signal" = {
    serviceConfig = { Restart = lib.mkOverride 90 "always"; };
    after = [
      "podman-network-netbird_default.service"
      "podman-volume-netbird_netbird-signal.service"
    ];
    requires = [
      "podman-network-netbird_default.service"
      "podman-volume-netbird_netbird-signal.service"
    ];
    partOf = [ "podman-compose-netbird-root.target" ];
    wantedBy = [ "podman-compose-netbird-root.target" ];
  };

  # Networks
  systemd.services."podman-network-netbird_default" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f netbird_default";
    };
    script = ''
      podman network inspect netbird_default || podman network create netbird_default
    '';
    partOf = [ "podman-compose-netbird-root.target" ];
    wantedBy = [ "podman-compose-netbird-root.target" ];
  };

  # Volumes
  systemd.services."podman-volume-netbird_netbird-mgmt" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect netbird_netbird-mgmt || podman volume create netbird_netbird-mgmt
    '';
    partOf = [ "podman-compose-netbird-root.target" ];
    wantedBy = [ "podman-compose-netbird-root.target" ];
  };
  systemd.services."podman-volume-netbird_netbird-signal" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect netbird_netbird-signal || podman volume create netbird_netbird-signal
    '';
    partOf = [ "podman-compose-netbird-root.target" ];
    wantedBy = [ "podman-compose-netbird-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-netbird-root" = {
    unitConfig = { Description = "Root target generated by compose2nix."; };
    wantedBy = [ "multi-user.target" ];
  };
}
