{ lib, pkgs, ... }:
with lib;
with lib.excalibur;
let
in
# newUser = name: {
  #   isNormalUser = true;
  #   createHome = true;
  #   home = "/home/${name}";
  #   shell = pkgs.zsh;
  # };
  # findEnabledServices = { serviceName }: builtins.filter (name: let
  #   cfg = self.nixosConfigurations.${name}.config.services.${serviceName}.enable;
  #   in cfg) (builtins.attrNames self.nixosConfigurations);
  # searxEnabledSystems = findEnabledServices { serviceName = "searx"; };
  # searxURLs = map (host: {
  #   # You need to obtain the port for each service dynamically if it varies; otherwise, specify it directly if constant
  #   url = "http://${host}:${cfg.port}"; # Replace PORT with the actual port or a method to retrieve it dynamically
  # }) searxEnabledSystems;
{
  imports = [ ./hardware.nix ];

  excalibur = {
    user = {
      name = "juca";
      fullName = "Reinaldo P Jr";
      email = "reinaldo800@gmail.com";
      extraGroups = [
        "wheel"
        "docker"
      ];
      uid = 10000;
    };
    suites = {
      public-hosting = {
        enable = true;
        interface = "eno1";
        log-to-kafka = true;
      };
      observability = {
        enable = true;
        loki = true;
        prometheus = true;
      };
      kafka = {
        enable = true;
        connect-server = true;
        timescale-server = true;
        schema-server = true;
        zookeeper-id = 2;
        servers = ''
          server.1=chesty:2888:3888
          server.2=0.0.0.0:2888:3888
          server.3=daly:2888:3888
          server.4=lucas:2888:3888
        '';
      };
    };

    archetypes = {
      server = {
        enable = true;
        k8s = false;
        role = "worker";
        hostId = "119db424";
      };
    };

    tools = {
      attic = enabled;
    };

    services = {
      # onlyoffice = { enable = true; };
      remark42 = {
        enable = true;
        port = 11842;
      };
      firefly = enabled;
      firefly-plaid-connector = enabled;
      excalibur-blog = enabled;
      nextcloud = {
        enable = true;
      };
      ldap-client = {
        enable = mkForce false;
      };
      netbird = enabled;
      uptime-kuma = enabled;
      grafana = {
        enable = true;
        datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            access = "proxy";
            url = "http://webb:9011";
          }
          {
            name = "Loki";
            type = "loki";
            access = "proxy";
            url = "http://webb:3030";
          }
        ];
      };
      collabora = enabled;
      keycloak = {
        enable = true;
        port = 43852;
      };
      attic-watch-store = enabled;
      nixery = enabled;
      docker = enabled;
      minio = enabled;
      mlflow = enabled;
      # airflow = enabled;
      # label-studio = enabled;
      vaultwarden = enabled;
      mattermost = enabled;
      paperless = enabled;

      mysql = {
        backupEnable = true;
        backupLocation = "/persist/mysqlBackups/";
      };

      photoprism = {
        enable = true;
        originalsPath = "/webb/media/photos";
      };

      borgbackup = {
        enable = true;
        jobs = {
          "excalibur" = {
            paths = [
              "/persist"
              "/webb/media/photos"
              "/webb/kubernetes"
              "/webb/backups/openwrt-backups"
              "/var/lib/paperless"
              "/var/lib/minio"
              "/var/lib/label-studio"
              "/var/lib/mattermost/files"
              "/var/lib/remark42/"
            ];
            repo = "mcamp@reckless:/mnt/backups/webb";
            startAt = "daily";
          };
          "webb_rsync" = {
            paths = [
              "/persist"
              "/webb/media/photos"
              "/webb/kubernetes"
              "/webb/backups/openwrt-backups"
              "/var/lib/paperless"
              "/var/lib/minio"
              "/var/lib/label-studio"
              "/var/lib/mattermost/files"
              "/var/lib/remark42/"
            ];
            repo = "de3288@de3288.rsync.net:/data2/home/de3288/backups/webb";
            startAt = "daily";
          };
        };
      };
      postgresql = {
        enable = true;
        enableTCPIP = true;
        backupEnable = true;
        backupLocation = "/persist/postgresqlBackups/";
        authentication = [
          "local all root trust"
          "local all postgres peer"
          "host all all 127.0.0.1/0 reject"
          "host all all ::0/0 reject"
        ];
      };
      wireguard = {
        enable = true;
        port = 1149;
        ips = [ "10.100.0.1/24" ];
        peers = [
          {
            # butler
            publicKey = "Thdtm9iUmcZFgFMiJUm0T0EaBe/gvfmcBHrSi5Gvfm8=";
            presharedKeyFile = "/var/lib/wireguard/wg0-preshared-key";
            allowedIPs = [ "10.100.0.2/32" ];
          }
          {
            # phone
            publicKey = "cq5+lO9tjEom1pUuXtb9rfAfSN6DZxDZkKWdVQ6Cokw=";
            presharedKeyFile = "/var/lib/wireguard/wg0-preshared-key";
            allowedIPs = [ "10.100.0.3/32" ];
          }
        ];
      };
      matomo = enabled;
      zfs-key-server = {
        enable = true;
        port = 8123;
        tang-servers = [
          "http://daly:1234"
          "http://lucas:1234"
          "http://reckless:1234"
          "http://chesty:1234"
          # "http://ermy:1234"
        ];
      };
      user-secrets = {
        enable = true;
        users.mcamp = {
          files = [
            "id_ed25519"
            "passwords"
          ];
        };
      };

      vault-agent = {
        enable = true;
        settings = {
          vault = {
            address = "https://vault.lan.aiexcalibur.com";
            role-id = "/var/lib/vault/webb/role-id";
            secret-id = "/var/lib/vault/webb/secret-id";
          };
        };
      };
    };
    nfs.client = enabled;
  };

  system.stateVersion = "23.05";
}
