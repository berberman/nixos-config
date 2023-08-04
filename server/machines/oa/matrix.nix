{ pkgs, lib, config, ... }:

let serverName = "mechdancer.org";
in {
  networking.firewall.allowedTCPPorts = [ 443 80 8448 ];

  services.postgresql = {
    enable = true;
    settings = {
      max_connections = 100;
      shared_buffers = "2048 MB";
      work_mem = "32 MB";
      maintenance_work_mem = "512 MB";
      effective_io_concurrency = 100;
      random_page_cost = 1.25;
      max_wal_size = "2048 MB";
      max_worker_processes = 6;
      max_parallel_workers_per_gather = 2;
      max_parallel_maintenance_workers = 2;
      max_parallel_workers = 6;
    };
  };
  services.postgresql.initialScript = pkgs.writeText "synapse-init.sql" ''
    CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
    CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
      TEMPLATE template0
      LC_COLLATE = "C"
      LC_CTYPE = "C";
  '';

  services.nginx = {
    virtualHosts = {
      "matrix.${serverName}" = {
        enableACME = true;
        forceSSL = true;
        locations."/".extraConfig = ''
          return 404;
        '';
        locations."/_matrix".proxyPass = "http://[::1]:8008";
        locations."/_synapse/client".proxyPass = "http://[::1]:8008";
      };
      "chat.${serverName}" = {
        enableACME = true;
        forceSSL = true;
        root = pkgs.element-web.override {
          conf = {
            default_server_config = {
              "m.homeserver" = {
                base_url = "https://matrix.${serverName}";
                server_name = serverName;
              };
            };
          };
        };
      };
    };
  };

  services.matrix-synapse = {
    enable = true;
    withJemalloc = true;
    settings = {
      enable_registration = true;
      dynamic_thumbnails = true;
      url_preview_enabled = true;
      registration_requires_token = true;
      server_name = serverName;
      listeners = [{
        port = 8008;
        bind_addresses = [ "::1" ];
        type = "http";
        tls = false;
        x_forwarded = true;
        resources = [{
          names = [ "client" "federation" ];
          compress = true;
        }];
      }];
    };
    extraConfigFiles = [ config.age.secrets.matrix-synapse-registration.path ];
  };
}
