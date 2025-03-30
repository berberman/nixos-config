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
        locations."/_matrix".proxyPass = "http://127.0.0.1:8008";
        locations."/_synapse/client".proxyPass = "http://127.0.0.1:8008";
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
        bind_addresses = [ "127.0.0.1" ];
        type = "http";
        tls = false;
        x_forwarded = true;
        resources = [{
          names = [ "client" "federation" ];
          compress = true;
        }];
      }];
      app_service_config_files =
        [ "/var/lib/matrix-synapse/telegram-registration.yaml" ];
    };
    extraConfigFiles = [ config.age.secrets.matrix-synapse-registration.path ];
  };

  services.matrix-appservices = {
    homeserverDomain = serverName;
    homeserverURL = "https://matrix.${serverName}";
    addRegistrationFiles = true;
    services.discord = {
      port = 29334;
      format = "mautrix-go";
      package = pkgs.mautrix-discord;
      settings = {
        bridge = {
          message_error_notices = false;
          permissions = {
            "*" = "relay";
            "@berberman:mozilla.org" = "admin";
          };
          encryption = {
            allow = true;
            default = true;
            allow_key_sharing = true;
          };
        };
        homeserver = { async_media = true; };
      };
    };
  };

  services.mautrix-telegram = {
    enable = true;

    environmentFile = config.age.secrets.mautrix-telegram.path;

    settings = {
      homeserver = {
        address = "http://127.0.0.1:8008";
        domain = serverName;
      };
      appservice = let port = 29317;
      in {
        address = "http://127.0.0.1:${toString port}";
        hostname = "127.0.0.1";
        inherit port;
        provisioning.enabled = false;
        id = "telegram";
        public = { enabled = false; };
        database = "postgresql:///mautrix-telegram?host=/run/postgresql";
      };
      bridge = {
        animated_sticker = {
          target = "webp";
          convert_from_webm = true;
        };
        permissions = {
          "*" = "relaybot";
          "@berberman:mozilla.org" = "admin";
        };
        encryption = {
          allow = true;
          default = true;
          allow_key_sharing = true;
        };
        relaybot = { authless_portals = false; };
      };
      telegram = {
        api_id = 611335;
        api_hash = "d524b414d21f4d37f08684c1df41ac9c";
        device_info = { app_version = "3.5.2"; };
      };
    };
  };

  systemd.services.mautrix-telegram.serviceConfig = {
    User = "matrix-synapse";
    Group = "matrix-synapse";
    DynamicUser = lib.mkForce false;
  };
}
