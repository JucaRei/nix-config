{
  options,
  config,
  lib,
  ...
}:
with lib;
with lib.excalibur;
let
  cfg = config.excalibur.suites.public-hosting;
  jsonValue =
    with types;
    let
      valueType =
        nullOr (oneOf [
          bool
          int
          float
          str
          (lazyAttrsOf valueType)
          (listOf valueType)
        ])
        // {
          description = "JSON value";
          emptyValue.value = { };
        };
    in
    valueType;
in
{
  options.excalibur.suites.public-hosting = with types; {
    enable = mkBoolOpt false "Whether or not to enable common public-hosting configuration.";
    interface = mkOpt str "eno1" "Interface to use for the LAN Instance";
    pub-ip = mkOpt str "10.8.0.42" "IP to use for the Public Instance";
    log-to-kafka = mkBoolOpt false "Enables the Traefik log Kafka Producer service";
    entrypoints = mkOption {
      type = jsonValue;
      default = {
        web = {
          address = "0.0.0.0:80";
        };
        metrics = {
          address = "0.0.0.0:58082";
        };
      };
      example = {
        web = {
          address = "0.0.0.0:80";
        };
      };
      description = "List of entrypoints for Traefik, mapping names to their address.";
    };
  };

  config = {
    excalibur = {
      # kafka-producers = { traefik-logs = { enable = cfg.log-to-kafka; }; };

      services = {
        prometheus.additionalScrapeConfigs = [
          {
            job_name = "pub-traefik-monitor";
            static_configs = [ { targets = [ "${cfg.pub-ip}:58082" ]; } ];
          }
        ];
        searx = mkIf cfg.enable {
          enable = true;
          port = 3249;
        };
        traefik = mkIf cfg.enable {
          enable = true;
          insecure = true;
          entrypoints = cfg.entrypoints;
          domains = [
            "aiexcalibur.com"
            "matt-camp.com"
          ];
          dynamicConfigOptions = {
            http.middlewares.cloudflarewarp = {
              plugin = {
                cloudflarewarp = {
                  disableDefault = false;
                };
              };
            };
            http.middlewares.fail2ban = {
              plugin = {
                fail2ban = {
                  rules = {
                    bantime = "3h";
                    enabled = true;
                    findtime = "10m";
                    maxretry = 4;
                  };
                };
              };
            };
            http.routers.matomo = {
              rule = "Host(`matomo.aiexcalibur.com`)";
              entryPoints = [ "websecure" ];
              service = "matomo";
            };

            http.services.matomo = {
              loadBalancer.servers = [ { url = "http://webb:16969"; } ];
            };
            http.routers.blog-comments = {
              rule = "Host(`remark.aiexcalibur.com`)";
              entryPoints = [ "websecure" ];
              service = "blog-comments";
            };

            http.services.blog-comments = {
              loadBalancer.servers = [ { url = "http://webb:11842"; } ];
            };

            http.routers.blog = {
              rule = "Host(`blog.aiexcalibur.com`) || Host(`aiexcalibur.com`)";
              entryPoints = [ "websecure" ];
              service = "blog";
            };

            http.services.blog = {
              loadBalancer.servers = [
                { url = "http://reckless:28345"; }
                { url = "http://daly:28345"; }
                { url = "http://chesty:28345"; }
                { url = "http://lucas:28345"; }
              ];
            };

            http.routers.keycloak = {
              rule = "Host(`keycloak.aiexcalibur.com`)";
              entryPoints = [ "websecure" ];
              service = "keycloak";
            };

            http.services.keycloak = {
              loadBalancer.servers = [ { url = "http://webb:43852"; } ];
            };

            http.routers.collabora = {
              rule = "Host(`collabora.aiexcalibur.com`)";
              entryPoints = [ "websecure" ];
              service = "collabora";
            };

            http.services.collabora = {
              loadBalancer.servers = [ { url = "http://webb:19980"; } ];
            };

            http.routers.onlyoffice-office = {
              rule = "Host(`office.aiexcalibur.com`)";
              entryPoints = [ "websecure" ];
              service = "onlyoffice";
            };

            http.services.onlyoffice = {
              loadBalancer.servers = [ { url = "http://lucas:13449"; } ];
            };

            http.routers.nextcloud = {
              rule = "Host(`cloud.aiexcalibur.com`)";
              entryPoints = [ "websecure" ];
              service = "nextcloud";
            };

            http.services.nextcloud = {
              loadBalancer.servers = [ { url = "http://webb:13244"; } ];
            };

            # http.routers.adhoc = {
            #   rule = "Host(`adhoc.aiexcalibur.com`)";
            #   entryPoints = [ "websecure" ];
            #   service = "adhoc";
            # };

            # http.services.adhoc = {
            #   loadBalancer.servers = [{ url = "http://reckless:5000"; }];
            # };

            http.routers.aiexcalibur = {
              rule = "Host(`matt-camp.com`)";
              entryPoints = [ "websecure" ];
              service = "aiexcalibur";
              middlewares = [ "cloudflarewarp" ];
            };

            http.services.matt-camp = {
              loadBalancer.servers = [ { url = "http://lucas:4356"; } ];
            };

            http.services.aiexcalibur = {
              loadBalancer.servers = [ { url = "http://lucas:4356"; } ];
            };

            http.routers.searx = {
              rule = "Host(`searx.aiexcalibur.com`)";
              entryPoints = [ "websecure" ];
              service = "searx";
              middlewares = [ "cloudflarewarp" ];
            };

            http.services.searx = {
              loadBalancer.servers = [
                { url = "http://webb:3249"; }
                { url = "http://daly:8181"; }
                { url = "http://chesty:3249"; }
                { url = "http://lucas:3249"; }
                { url = "http://reckless:3249"; }
              ];

              loadBalancer.healthCheck = {
                path = "/";
                interval = "10s";
                timeout = "5s";
              };
            };

            http.routers.photoprism = {
              rule = "Host(`photos.aiexcalibur.com`)";
              entryPoints = [ "websecure" ];
              service = "photoprism";
              middlewares = [ "cloudflarewarp" ];
            };

            http.services.photoprism = {
              loadBalancer.servers = [ { url = "http://webb:9080"; } ];
            };

            http.routers.attic = {
              rule = "Host(`attic.aiexcalibur.com`)";
              entryPoints = [ "websecure" ];
              service = "attic";
            };

            http.services.attic = {
              loadBalancer.servers = [ { url = "http://reckless:8082"; } ];
            };

            http.routers.bitwarden = {
              rule = "Host(`bw.aiexcalibur.com`)";
              entryPoints = [ "websecure" ];
              service = "bitwarden";
              middlewares = [ "cloudflarewarp" ];
            };

            http.services.bitwarden = {
              loadBalancer.servers = [ { url = "http://webb:8989"; } ];
              loadBalancer.healthCheck = {
                path = "/alive";
                interval = "10s";
                timeout = "5s";
              };
            };

            http.routers.mattermost = {
              rule = "Host(`mattermost.aiexcalibur.com`)";
              entryPoints = [ "websecure" ];
              service = "mattermost";
              middlewares = [ "cloudflarewarp" ];
            };

            http.routers.mm = {
              rule = "Host(`mm.aiexcalibur.com`)";
              entryPoints = [ "websecure" ];
              service = "mattermost";
              middlewares = [ "cloudflarewarp" ];
            };

            http.services.mattermost = {
              loadBalancer.servers = [ { url = "http://webb:8065"; } ];
            };
          };
        };
        keepalived = mkIf cfg.enable {
          enable = true;
          instances = {
            "pub-excalibur" = {
              interface = cfg.interface;
              ips = [ cfg.pub-ip ];
              state = "MASTER";
              priority = 50;
              virtualRouterId = 51;
            };
          };
        };
      };
    };
  };
}
