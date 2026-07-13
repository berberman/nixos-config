{
  config,
  lib,
  pkgs,
  ...
}:

let
  ##############################################################################

  probeTargets = {
    sso = {
      url = "https://sso.torus.icu/-/health/live/";
      tcpTarget = "sso.torus.icu:443";
      healthEndpoint = "/-/health/live/";
      scope = "business";
    };

    wakapi = {
      url = "https://wakapi.torus.icu/api/health";
      tcpTarget = "wakapi.torus.icu:443";
      healthEndpoint = "/api/health";
      scope = "business";
    };

    vaultwarden = {
      url = "https://bitwarden.torus.icu/alive";
      tcpTarget = "bitwarden.torus.icu:443";
      healthEndpoint = "/alive";
      scope = "business";
    };

    coder = {
      url = "https://coder.jackywang.page/healthz";
      tcpTarget = "coder.jackywang.page:443";
      healthEndpoint = "/healthz";
      scope = "business";
    };

    "pve-webui-union1" = {
      url = "https://union1.jackywang.page:8006/";
      tcpTarget = "union1.jackywang.page:8006";
      healthEndpoint = "/";
      scope = "management-webui";
    };

    "pve-webui-union2" = {
      url = "https://union2.jackywang.page:8006/";
      tcpTarget = "union2.jackywang.page:8006";
      healthEndpoint = "/";
      scope = "management-webui";
    };

    "pve-webui-union3" = {
      url = "https://union3.jackywang.page:8006/";
      tcpTarget = "union3.jackywang.page:8006";
      healthEndpoint = "/";
      scope = "management-webui";
    };
  };

  ##############################################################################

  curlFamilies = {
    auto = {
      curlArgs = [ ];
    };
    ipv4 = {
      curlArgs = [ "--ipv4" ];
    };
    ipv6 = {
      curlArgs = [ "--ipv6" ];
    };
  };

  httpFamilies = {
    auto = { };
    ipv4 = { };
    ipv6 = { };
  };

  tcpFamilies = {
    ipv4 = { };
    ipv6 = { };
  };

  ##############################################################################

  curlTargets = lib.foldl' (
    acc: service:
    let
      target = probeTargets.${service};
    in
    acc
    // lib.mapAttrs' (
      family: familyConfig:
      lib.nameValuePair "${service}-${family}" (
        target
        // {
          inherit family;
          curlArgs = familyConfig.curlArgs;
        }
      )
    ) curlFamilies
  ) { } (lib.attrNames probeTargets);

  curlWriteOut = pkgs.writeText "curl-probe-writeout.json" ''
    %{stderr}{"event":"curl_summary","curl":%{json},"response_headers":%{header_json}}
  '';

  mkCurlProbe = name: target: {
    description = "Verbose external HTTP probe for ${name}";

    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    unitConfig.StartLimitIntervalSec = 0;

    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec = "10s";

      # The unit shouldn't always be considered as failed if the request failed.
      SuccessExitStatus = [
        "5"
        "6"
        "7"
        "22"
        "28"
        "35"
        "52"
        "55"
        "56"
        "60"
      ];

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

  mkCurlTimer = name: target: {
    description = "Schedule verbose external HTTP probe for ${name}";

    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnBootSec = if target.family == "auto" then "25s" else "35s";
      OnUnitInactiveSec = if target.family == "auto" then "15s" else "30s";
      AccuracySec = "1s";
      RandomizedDelaySec = "8s";
      Unit = "curl-verbose-${name}.service";
    };
  };

  ##############################################################################

  mkHttpStaticConfigs =
    service: target:
    lib.mapAttrsToList (family: _: {
      targets = [ target.url ];

      labels = {
        inherit service family;
        scope = target.scope;
        health_endpoint = target.healthEndpoint;
        probe_type = "https";
        vantage = "external-nixos";
        blackbox_module = "http_https_${family}";
      };
    }) httpFamilies;

  httpStaticConfigs = lib.concatLists (lib.mapAttrsToList mkHttpStaticConfigs probeTargets);

  ##############################################################################

  mkTcpStaticConfigs =
    service: target:
    lib.mapAttrsToList (family: _: {
      targets = [ target.tcpTarget ];

      labels = {
        inherit service family;
        scope = target.scope;
        probe_type = "tcp-tls";
        vantage = "external-nixos";
        blackbox_module = "tcp_tls_${family}";
      };
    }) tcpFamilies;

  tcpStaticConfigs = lib.concatLists (lib.mapAttrsToList mkTcpStaticConfigs probeTargets);

  ##############################################################################

  blackboxConfig = pkgs.writeText "blackbox.yml" ''
    modules:
      http_https_auto:
        prober: http
        timeout: 2s
        http:
          method: GET
          valid_status_codes: [200]
          follow_redirects: false
          fail_if_not_ssl: true
          preferred_ip_protocol: ip6
          ip_protocol_fallback: true
          tls_config:
            min_version: TLS12

      http_https_ipv4:
        prober: http
        timeout: 2s
        http:
          method: GET
          valid_status_codes: [200]
          follow_redirects: false
          fail_if_not_ssl: true
          preferred_ip_protocol: ip4
          ip_protocol_fallback: false
          tls_config:
            min_version: TLS12

      http_https_ipv6:
        prober: http
        timeout: 2s
        http:
          method: GET
          valid_status_codes: [200]
          follow_redirects: false
          fail_if_not_ssl: true
          preferred_ip_protocol: ip6
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

      tcp_tls_ipv6:
        prober: tcp
        timeout: 2s
        tcp:
          tls: true
          preferred_ip_protocol: ip6
          ip_protocol_fallback: false
          tls_config:
            min_version: TLS12
  '';

  blackboxHttpScrapeConfig = {
    job_name = "blackbox-http-external";
    scrape_interval = "10s";
    scrape_timeout = "8s";
    metrics_path = "/probe";
    static_configs = httpStaticConfigs;

    relabel_configs = [
      {
        source_labels = [ "__address__" ];
        target_label = "__param_target";
      }
      {
        source_labels = [ "blackbox_module" ];
        target_label = "__param_module";
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
  };

  blackboxTcpScrapeConfig = {
    job_name = "blackbox-tcp-tls-external";
    scrape_interval = "15s";
    scrape_timeout = "8s";
    metrics_path = "/probe";
    static_configs = tcpStaticConfigs;

    relabel_configs = [
      {
        source_labels = [ "__address__" ];
        target_label = "__param_target";
      }
      {
        source_labels = [ "blackbox_module" ];
        target_label = "__param_module";
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
  };

  ##############################################################################

  dashboardDir = pkgs.runCommand "external-probe-dashboards" { } ''
    mkdir -p "$out"

    cat > "$out/external-probes.json" <<'JSON'
    {
      "annotations": {
        "list": []
      },
      "editable": false,
      "fiscalYearStartMonth": 0,
      "graphTooltip": 0,
      "links": [],
      "liveNow": false,
      "panels": [
        {
          "id": 1,
          "type": "stat",
          "title": "External HTTPS availability — auto",
          "description": "All endpoints using the automatic address-family path.",
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "gridPos": {
            "h": 4,
            "w": 24,
            "x": 0,
            "y": 0
          },
          "targets": [
            {
              "refId": "A",
              "expr": "probe_success{job=\"blackbox-http-external\",family=\"auto\"}",
              "legendFormat": "{{scope}} / {{service}}",
              "instant": true
            }
          ],
          "options": {
            "reduceOptions": {
              "values": false,
              "calcs": [
                "lastNotNull"
              ],
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
                    "0": {
                      "text": "DOWN",
                      "color": "red"
                    },
                    "1": {
                      "text": "UP",
                      "color": "green"
                    }
                  }
                }
              ],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "red",
                    "value": null
                  },
                  {
                    "color": "green",
                    "value": 1
                  }
                ]
              }
            },
            "overrides": []
          }
        },
        {
          "id": 9,
          "type": "stat",
          "title": "External HTTPS availability — IPv4",
          "description": "All endpoints forced to IPv4.",
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "gridPos": {
            "h": 4,
            "w": 24,
            "x": 0,
            "y": 4
          },
          "targets": [
            {
              "refId": "A",
              "expr": "probe_success{job=\"blackbox-http-external\",family=\"ipv4\"}",
              "legendFormat": "{{scope}} / {{service}}",
              "instant": true
            }
          ],
          "options": {
            "reduceOptions": {
              "values": false,
              "calcs": [
                "lastNotNull"
              ],
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
                    "0": {
                      "text": "DOWN",
                      "color": "red"
                    },
                    "1": {
                      "text": "UP",
                      "color": "green"
                    }
                  }
                }
              ],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "red",
                    "value": null
                  },
                  {
                    "color": "green",
                    "value": 1
                  }
                ]
              }
            },
            "overrides": []
          }
        },
        {
          "id": 10,
          "type": "stat",
          "title": "External HTTPS availability — IPv6",
          "description": "All endpoints forced to IPv6.",
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "gridPos": {
            "h": 4,
            "w": 24,
            "x": 0,
            "y": 8
          },
          "targets": [
            {
              "refId": "A",
              "expr": "probe_success{job=\"blackbox-http-external\",family=\"ipv6\"}",
              "legendFormat": "{{scope}} / {{service}}",
              "instant": true
            }
          ],
          "options": {
            "reduceOptions": {
              "values": false,
              "calcs": [
                "lastNotNull"
              ],
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
                    "0": {
                      "text": "DOWN",
                      "color": "red"
                    },
                    "1": {
                      "text": "UP",
                      "color": "green"
                    }
                  }
                }
              ],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "red",
                    "value": null
                  },
                  {
                    "color": "green",
                    "value": 1
                  }
                ]
              }
            },
            "overrides": []
          }
        },
        {
          "id": 2,
          "type": "timeseries",
          "title": "Address-family failures only",
          "description": "No series is shown while all endpoint and address-family probes are healthy.",
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "gridPos": {
            "h": 6,
            "w": 24,
            "x": 0,
            "y": 12
          },
          "targets": [
            {
              "refId": "A",
              "expr": "probe_success{job=\"blackbox-http-external\"} == 0",
              "legendFormat": "{{scope}} / {{service}} / {{family}}"
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
              "calcs": [
                "lastNotNull",
                "min"
              ]
            },
            "tooltip": {
              "mode": "multi",
              "sort": "desc"
            }
          }
        },
        {
          "id": 3,
          "type": "timeseries",
          "title": "HTTP total duration \u2014 all endpoints / families",
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "gridPos": {
            "h": 9,
            "w": 24,
            "x": 0,
            "y": 18
          },
          "targets": [
            {
              "refId": "A",
              "expr": "probe_duration_seconds{job=\"blackbox-http-external\"}",
              "legendFormat": "{{scope}} / {{service}} / {{family}}"
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
              "calcs": [
                "lastNotNull",
                "max"
              ]
            },
            "tooltip": {
              "mode": "multi",
              "sort": "desc"
            }
          },
          "description": "All HTTP probe series. Use the legend to isolate one endpoint or address family."
        },
        {
          "id": 4,
          "type": "timeseries",
          "title": "HTTP phases \u2014 successful probes only",
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "gridPos": {
            "h": 10,
            "w": 24,
            "x": 0,
            "y": 27
          },
          "targets": [
            {
              "refId": "A",
              "expr": "probe_http_duration_seconds{job=\"blackbox-http-external\"} and on (job, instance, service, family, scope) (probe_success{job=\"blackbox-http-external\"} == 1)",
              "legendFormat": "{{scope}} / {{service}} / {{family}} / {{phase}}"
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
              "calcs": [
                "lastNotNull",
                "max"
              ]
            },
            "tooltip": {
              "mode": "multi",
              "sort": "desc"
            }
          },
          "description": "All HTTP timing phases; failed probes are excluded because they do not have a complete phase breakdown."
        },
        {
          "id": 5,
          "type": "timeseries",
          "title": "HTTP response status \u2014 all endpoints / families",
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "gridPos": {
            "h": 8,
            "w": 12,
            "x": 0,
            "y": 37
          },
          "targets": [
            {
              "refId": "A",
              "expr": "probe_http_status_code{job=\"blackbox-http-external\"}",
              "legendFormat": "{{scope}} / {{service}} / {{family}}"
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
              "calcs": [
                "lastNotNull",
                "max"
              ]
            },
            "tooltip": {
              "mode": "multi",
              "sort": "desc"
            }
          }
        },
        {
          "id": 6,
          "type": "timeseries",
          "title": "TCP/TLS availability \u2014 all endpoints / families",
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "gridPos": {
            "h": 8,
            "w": 12,
            "x": 12,
            "y": 37
          },
          "targets": [
            {
              "refId": "A",
              "expr": "probe_success{job=\"blackbox-tcp-tls-external\"}",
              "legendFormat": "{{scope}} / {{service}} / {{family}}"
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
              "calcs": [
                "lastNotNull",
                "min"
              ]
            },
            "tooltip": {
              "mode": "multi",
              "sort": "desc"
            }
          }
        },
        {
          "id": 7,
          "type": "timeseries",
          "title": "TLS certificate remaining days \u2014 all endpoints / families",
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "gridPos": {
            "h": 8,
            "w": 12,
            "x": 0,
            "y": 45
          },
          "targets": [
            {
              "refId": "A",
              "expr": "(probe_ssl_earliest_cert_expiry{job=\"blackbox-http-external\"} - time()) / 86400",
              "legendFormat": "{{scope}} / {{service}} / {{family}}"
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
              "calcs": [
                "lastNotNull",
                "min"
              ]
            },
            "tooltip": {
              "mode": "multi",
              "sort": "desc"
            }
          }
        },
        {
        "id": 11,
        "type": "bargauge",
        "title": "Probe failure ratio — selected time range",
        "description": "Failure percentage over the selected dashboard time range, based on Blackbox probe samples.",
        "datasource": {
          "type": "prometheus",
          "uid": "prometheus"
        },
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 12,
          "y": 45
        },
        "targets": [
          {
            "refId": "A",
            "expr": "100 * (1 - avg_over_time(probe_success{job=\"blackbox-http-external\"}[$__range]))",
            "legendFormat": "{{scope}} / {{service}} / {{family}}",
            "instant": true
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "percent",
            "decimals": 3,
            "min": 0,
            "max": 100,
            "thresholds": {
              "mode": "absolute",
              "steps": [
                {
                  "color": "green",
                  "value": 0
                },
                {
                  "color": "yellow",
                  "value": 0.001
                },
                {
                  "color": "red",
                  "value": 1
                }
              ]
            }
          },
          "overrides": []
        },
        "options": {
          "orientation": "horizontal",
          "displayMode": "basic",
          "showUnfilled": true,
          "namePlacement": "auto",
          "valueMode": "color",
          "reduceOptions": {
            "values": false,
            "calcs": [
              "lastNotNull"
            ],
            "fields": ""
          }
        }
      }
      ],
      "refresh": "30s",
      "schemaVersion": 41,
      "tags": [
        "blackbox",
        "external",
        "k3s",
        "pve"
      ],
      "templating": {
        "list": []
      },
      "time": {
        "from": "now-1h",
        "to": "now"
      },
      "timezone": "browser",
      "title": "External Endpoint Diagnostics",
      "uid": "external-endpoint-diagnostics",
      "version": 4
    }
    JSON
  '';
in
{
  ##############################################################################

  systemd.services =
    (lib.mapAttrs' (
      name: target: lib.nameValuePair "curl-verbose-${name}" (mkCurlProbe name target)
    ) curlTargets)
    // {
      alloy.serviceConfig.SupplementaryGroups = lib.mkAfter [ "adm" ];
    };

  systemd.timers = lib.mapAttrs' (
    name: target: lib.nameValuePair "curl-verbose-${name}" (mkCurlTimer name target)
  ) curlTargets;

  services.journald.extraConfig = ''
    Storage=persistent
    SystemMaxUse=5G
    MaxRetentionSec=72h
  '';

  ##############################################################################

  services.prometheus.exporters.blackbox = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 9115;
    configFile = blackboxConfig;
    extraFlags = [ "--log.prober=warn" ];
  };

  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 9090;
    retentionTime = "14d";

    globalConfig = {
      scrape_interval = "15s";
      scrape_timeout = "10s";
      evaluation_interval = "15s";
    };

    scrapeConfigs = [
      blackboxHttpScrapeConfig
      blackboxTcpScrapeConfig
      {
        job_name = "prometheus-self";
        static_configs = [
          { targets = [ "127.0.0.1:9090" ]; }
        ];
      }
      {
        job_name = "blackbox-exporter-self";
        static_configs = [
          { targets = [ "127.0.0.1:9115" ]; }
        ];
      }
    ];
  };

  ##############################################################################

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

            options.path = dashboardDir;
          }
        ];
      };
    };
  };

  ##############################################################################

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

  ##############################################################################

  services.alloy = {
    enable = true;
    extraFlags = [ "--disable-reporting" ];
  };

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

      rule {
        source_labels = ["service"]
        regex         = "pve-webui-union[123]"
        target_label  = "scope"
        replacement   = "management-webui"
      }
    }

    loki.source.journal "curl_probes" {
      forward_to    = [loki.write.local.receiver]
      matches       = "SYSLOG_IDENTIFIER=curl-verbose-probe"
      relabel_rules = loki.relabel.curl_probe_labels.rules
      max_age       = "1h"

      labels = {
        source = "curl-verbose",
      }
    }
  '';
}
