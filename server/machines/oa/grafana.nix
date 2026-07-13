{
  pkgs,
  config,
  lib,
  ...
}:

let
  dashboardDir = pkgs.runCommand "external-probe-dashboards" { } ''
    mkdir -p "$out"

    cat > "$out/external-probes.json" <<'JSON'
    {
      "annotations": { "list": [] },
      "editable": false,
      "fiscalYearStartMonth": 0,
      "graphTooltip": 0,
      "links": [],
      "liveNow": false,
      "panels": [
        {
          "id": 1,
          "type": "stat",
          "title": "HTTPS healthz availability",
          "datasource": { "type": "prometheus", "uid": "prometheus" },
          "gridPos": { "h": 5, "w": 24, "x": 0, "y": 0 },
          "targets": [
            {
              "refId": "A",
              "expr": "min by (service) (probe_success{job=\"blackbox-http-ipv4\"})",
              "legendFormat": "{{service}}",
              "instant": true
            }
          ],
          "options": {
            "reduceOptions": {
              "values": false,
              "calcs": [ "lastNotNull" ],
              "fields": ""
            },
            "orientation": "auto",
            "textMode": "auto",
            "colorMode": "background",
            "graphMode": "none",
            "justifyMode": "auto"
          },
          "fieldConfig": {
            "defaults": {
              "decimals": 0,
              "mappings": [
                {
                  "type": "value",
                  "options": {
                    "0": { "text": "DOWN", "color": "red" },
                    "1": { "text": "UP", "color": "green" }
                  }
                }
              ],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  { "color": "red", "value": null },
                  { "color": "green", "value": 1 }
                ]
              }
            },
            "overrides": []
          }
        },
        {
          "id": 2,
          "type": "timeseries",
          "title": "HTTP total probe duration",
          "datasource": { "type": "prometheus", "uid": "prometheus" },
          "gridPos": { "h": 8, "w": 12, "x": 0, "y": 5 },
          "targets": [
            {
              "refId": "A",
              "expr": "probe_duration_seconds{job=\"blackbox-http-ipv4\"}",
              "legendFormat": "{{service}}"
            }
          ],
          "fieldConfig": {
            "defaults": {
              "unit": "s",
              "min": 0
            },
            "overrides": []
          },
          "options": {
            "legend": {
              "displayMode": "table",
              "placement": "bottom",
              "calcs": [ "lastNotNull", "max" ]
            },
            "tooltip": { "mode": "multi", "sort": "desc" }
          }
        },
        {
          "id": 3,
          "type": "timeseries",
          "title": "HTTP phases — successful probes only",
          "datasource": { "type": "prometheus", "uid": "prometheus" },
          "gridPos": { "h": 8, "w": 12, "x": 12, "y": 5 },
          "targets": [
            {
              "refId": "A",
              "expr": "probe_http_duration_seconds{job=\"blackbox-http-ipv4\"} and on (job, instance) (probe_success{job=\"blackbox-http-ipv4\"} == 1)",
              "legendFormat": "{{service}} / {{phase}}"
            }
          ],
          "fieldConfig": {
            "defaults": {
              "unit": "s",
              "min": 0
            },
            "overrides": []
          },
          "options": {
            "legend": {
              "displayMode": "table",
              "placement": "bottom",
              "calcs": [ "lastNotNull", "max" ]
            },
            "tooltip": { "mode": "multi", "sort": "desc" }
          }
        },
        {
          "id": 4,
          "type": "timeseries",
          "title": "HTTP response status",
          "datasource": { "type": "prometheus", "uid": "prometheus" },
          "gridPos": { "h": 8, "w": 12, "x": 0, "y": 13 },
          "targets": [
            {
              "refId": "A",
              "expr": "probe_http_status_code{job=\"blackbox-http-ipv4\"}",
              "legendFormat": "{{service}}"
            }
          ],
          "fieldConfig": {
            "defaults": {
              "decimals": 0,
              "min": 0
            },
            "overrides": []
          },
          "options": {
            "legend": {
              "displayMode": "table",
              "placement": "bottom",
              "calcs": [ "lastNotNull", "max" ]
            },
            "tooltip": { "mode": "multi", "sort": "desc" }
          }
        },
        {
          "id": 5,
          "type": "timeseries",
          "title": "TLS/TCP 443 availability",
          "datasource": { "type": "prometheus", "uid": "prometheus" },
          "gridPos": { "h": 8, "w": 12, "x": 12, "y": 13 },
          "targets": [
            {
              "refId": "A",
              "expr": "probe_success{job=\"blackbox-tcp-tls-ipv4\"}",
              "legendFormat": "{{service}}"
            }
          ],
          "fieldConfig": {
            "defaults": {
              "min": 0,
              "max": 1,
              "decimals": 0
            },
            "overrides": []
          },
          "options": {
            "legend": {
              "displayMode": "table",
              "placement": "bottom",
              "calcs": [ "lastNotNull", "min" ]
            },
            "tooltip": { "mode": "multi", "sort": "desc" }
          }
        },
        {
          "id": 6,
          "type": "timeseries",
          "title": "TLS certificate remaining days",
          "datasource": { "type": "prometheus", "uid": "prometheus" },
          "gridPos": { "h": 8, "w": 24, "x": 0, "y": 21 },
          "targets": [
            {
              "refId": "A",
              "expr": "(probe_ssl_earliest_cert_expiry{job=\"blackbox-http-ipv4\"} - time()) / 86400",
              "legendFormat": "{{service}}"
            }
          ],
          "fieldConfig": {
            "defaults": {
              "unit": "d",
              "min": 0
            },
            "overrides": []
          },
          "options": {
            "legend": {
              "displayMode": "table",
              "placement": "bottom",
              "calcs": [ "lastNotNull", "min" ]
            },
            "tooltip": { "mode": "multi", "sort": "desc" }
          }
        }
      ],
      "refresh": "10s",
      "schemaVersion": 41,
      "tags": [ "blackbox", "external", "k3s" ],
      "templating": { "list": [] },
      "time": { "from": "now-6h", "to": "now" },
      "timezone": "browser",
      "title": "External Endpoint Diagnostics",
      "uid": "external-endpoint-diagnostics",
      "version": 1
    }
    JSON
  '';

  blackboxConfig = pkgs.writeText "blackbox.yml" ''
    modules:
      http_healthz_ipv4:
        prober: http
        timeout: 2s
        http:
          method: GET
          valid_status_codes: [200]
          follow_redirects: false
          preferred_ip_protocol: ip4
          ip_protocol_fallback: false
          tls_config:
            min_version: TLS12

      tcp_tls_ipv4:
        prober: tcp
        timeout: 2s
        tcp:
          tls: true
          preferred_ip_protocol: ip4
          ip_protocol_fallback: false
          tls_config:
            min_version: TLS12
  '';
in
{
  services.prometheus.exporters.blackbox = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 9115;
    configFile = blackboxConfig;

    extraFlags = [
      "--log.prober=warn"
    ];
  };

  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 9090;
    retentionTime = "14d";

    globalConfig = {
      scrape_interval = "3s";
      scrape_timeout = "2800ms";
      evaluation_interval = "15s";
    };

    scrapeConfigs = [
      {
        job_name = "blackbox-http-ipv4";
        metrics_path = "/probe";

        params = {
          module = [ "http_healthz_ipv4" ];
        };

        static_configs = [
          {
            targets = [
              "https://sso.torus.icu/-/health/live/"
            ];
            labels = {
              service = "authentik";
              health_endpoint = "/-/health/live/";
              vantage = "external-nixos";
              probe_type = "https-health";
            };

          }
          {
            targets = [
              "https://wakapi.torus.icu/api/health"
            ];
            labels = {
              service = "wakapi";
              health_endpoint = "/api/health";
              vantage = "external-nixos";
              probe_type = "https-health";
            };
          }
          {
            targets = [
              "https://bitwarden.torus.icu/alive"
            ];
            labels = {
              service = "vaultwarden";
              health_endpoint = "/alive";
              vantage = "external-nixos";
              probe_type = "https-health";
            };
          }
          {
            targets = [
              "https://coder.jackywang.page/healthz"
            ];

            labels = {
              service = "coder";
              vantage = "external-nixos";
              health_endpoint = "/healthz";
              probe_type = "https-healthz";
            };
          }
        ];

        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "__param_target";
          }
          {
            source_labels = [ "__param_target" ];
            target_label = "instance";
          }
          {
            target_label = "__address__";
            replacement = "127.0.0.1:9115";
          }
        ];
      }

      {
        job_name = "blackbox-tcp-tls-ipv4";
        metrics_path = "/probe";

        params = {
          module = [ "tcp_tls_ipv4" ];
        };

        static_configs = [
          {
            targets = [
              "sso.torus.icu:443"
              "coder.jackywang.page:443"
              "bitwarden.torus.icu:443"
              "wakapi.torus.icu:443"
            ];

            labels = {
              vantage = "external-nixos";
              probe_type = "tcp-tls";
            };
          }
        ];

        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "__param_target";
          }
          {
            source_labels = [ "__param_target" ];
            target_label = "instance";
          }
          {
            target_label = "__address__";
            replacement = "127.0.0.1:9115";
          }
        ];
      }

      {
        job_name = "prometheus-self";
        static_configs = [
          {
            targets = [ "127.0.0.1:9090" ];
          }
        ];
      }

      {
        job_name = "blackbox-exporter-self";
        static_configs = [
          {
            targets = [ "127.0.0.1:9115" ];
          }
        ];
      }
    ];
  };

  services.grafana = {
    enable = true;

    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        domain = "localhost";
        root_url = "http://localhost:3000/";
      };

      security = {
        admin_user = "admin";
        admin_password = "$__file{${config.age.secrets.grafana-admin-password.path}}";
        secret_key = "$__file{${config.age.secrets.grafana-secret-key.path}}";
        cookie_secure = false;
      };

      users = {
        allow_sign_up = false;
        allow_org_create = false;
      };

      analytics = {
        reporting_enabled = false;
        check_for_updates = false;
      };
    };

    provision = {
      datasources.settings = {
        apiVersion = 1;

        datasources = [
          {
            name = "Prometheus";
            uid = "prometheus";
            type = "prometheus";
            access = "proxy";
            url = "http://127.0.0.1:9090";
            isDefault = true;
            editable = false;
          }
          {
            name = "Loki";
            uid = "loki";
            type = "loki";
            access = "proxy";
            url = "http://127.0.0.1:3100";
            isDefault = false;
            editable = false;
          }
        ];
      };

      dashboards.settings = {
        apiVersion = 1;

        providers = [
          {
            name = "external-probes";
            orgId = 1;
            folder = "External Probes";
            type = "file";
            disableDeletion = true;
            allowUiUpdates = false;

            options = {
              path = dashboardDir;
            };
          }
        ];
      };
    };
  };

  services.loki = {
    enable = true;
    dataDir = "/var/lib/loki";

    configuration = {
      auth_enabled = false;

      server = {
        http_listen_address = "127.0.0.1";
        http_listen_port = 3100;
      };

      common = {
        path_prefix = "/var/lib/loki";

        replication_factor = 1;

        ring = {
          kvstore = {
            store = "inmemory";
          };
        };

        storage = {
          filesystem = {
            chunks_directory = "/var/lib/loki/chunks";
            rules_directory = "/var/lib/loki/rules";
          };
        };
      };

      schema_config = {
        configs = [
          {
            from = "2024-01-01";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";

            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];
      };

      compactor = {
        working_directory = "/var/lib/loki/compactor";
        retention_enabled = true;
        delete_request_store = "filesystem";
      };

      limits_config = {
        retention_period = "72h";
      };
    };
  };
  services.alloy = {
    enable = true;
    extraFlags = [ "--disable-reporting" ];
  };

  systemd.services.alloy.serviceConfig.SupplementaryGroups = lib.mkAfter [
    "adm"
  ];

  environment.etc."alloy/curl-probes.alloy".text = ''
    loki.write "local" {
      endpoint {
        url = "http://127.0.0.1:3100/loki/api/v1/push"
      }
    }

    loki.relabel "curl_probe_labels" {
      forward_to = []

      rule {
        source_labels = ["__journal__systemd_unit"]
        regex         = "curl-verbose-(.+)-(auto|ipv4|ipv6)\\.service"
        target_label  = "service"
        replacement   = "$1"
      }
      rule {
        source_labels = ["__journal__systemd_unit"]
        regex         = "curl-verbose-(.+)-(auto|ipv4|ipv6)\\.service"
        target_label  = "family"
        replacement   = "$2"
      }
    }

    loki.source.journal "curl_probes" {
      forward_to    = [loki.write.local.receiver]
      matches       = "SYSLOG_IDENTIFIER=curl-verbose-probe"
      relabel_rules = loki.relabel.curl_probe_labels.rules

      labels = {
        source = "curl-verbose",
      }
      max_age = "1h"
    }
  '';
}
