{ lib, config, pkgs, ... }:
with lib;
with lib.excalibur;
let cfg = config.excalibur.services.paperless;
in {
  options.excalibur.services.paperless = with types; {
    enable = mkBoolOpt false "Enable Mattermost;";
    dataDir = mkOpt str "/var/lib/paperless" "Location to store data";
    mediaDir = mkOpt str "/var/lib/paperless/media" "Location to store media";
    consumptionDir =
      mkOpt str "/var/lib/paperless/consume" "Place to import files from";
    address = mkOpt str "localhost" "Host address";
    gotenbergPort = mkOpt str "3000" "Gotenberg Port";
    tikaPort = mkOpt str "9998" "Tika Port";
    domainName = mkOpt str "https://docs.lan.aiexcalibur.com" "domain to use";
    role-id =
      mkOpt str config.excalibur.services.vault-agent.settings.vault.role-id
      "Absolute path to the Vault role-id";
    secret-id =
      mkOpt str config.excalibur.services.vault-agent.settings.vault.secret-id
      "Absolute path to the Vault secret-id";
    vault-path = mkOpt str "secret/excalibur/paperless"
      "The Vault path to the KV containing the KVs that are for each database";
    kvVersion = mkOption {
      type = enum [ "v1" "v2" ];
      default = "v2";
      description = "KV store version";
    };
    vault-address = mkOption {
      type = str;
      default = config.excalibur.services.vault-agent.settings.vault.address;
      description = "The address of your Vault";
    };
  };

  config = mkIf cfg.enable {
    excalibur.services.postgresql = {
      enable = true;
      authentication = [
        "local paperless paperless trust"
        "host paperless paperless 127.0.0.1/32 trust"
      ];
      databases = [{
        name = "paperless";
        user = "paperless";
      }];
    };

    services.paperless = {
      enable = true;
      dataDir = cfg.dataDir;
      mediaDir = cfg.mediaDir;
      consumptionDir = cfg.consumptionDir;
      passwordFile = "/var/lib/vault/paperless.pass";
      address = "0.0.0.0";
      port = 28981;
      user = "paperless";
      package = pkgs.paperless-ngx;
      settings = {
        PAPERLESS_URL = cfg.domainName;

        # NOTE: Be sure to set a password for the paperless db user cause i had issues being able to connect
        # required setting up the db in one go and then deploy again with this.. my db game needs work
        # if you neglect the above there is a chance it will use SQLite as a fall back.. but might not now
        # that I set a dbhost. ¯\_(ツ)_/¯
        PAPERLESS_DBHOST = "/run/postgresql";
        # PAPERLESS_DBHOST = "127.0.0.1";

        PAPERLESS_OCR_LANGUAGE = "eng";
        PAPERLESS_TASK_WORKERS = 4;
        PAPERLESS_THREADS_PER_WORKER = 8;

        PAPERLESS_TIKA_ENABLED = true;
        PAPERLESS_TIKA_ENDPOINT = "http://127.0.0.1:${cfg.tikaPort}";
        PAPERLESS_TIKA_GOTENBERG_ENDPOINT =
          "http://127.0.0.1:${cfg.gotenbergPort}";

        PAPERLESS_EMAIL_TASK_CRON = "*/5 * * * *";
      };
    };

    systemd.services.paperlessPasswordFile = {
      description = "Create Paperless environment file";
      serviceConfig = {
        Type = "oneshot";
        User =
          "root"; # Use the root user to create the folder and set permissions
        ExecStartPre =
          "${pkgs.coreutils}/bin/chown root:root /var/lib/vault"; # Set folder ownership to root
        ExecStart =
          "${pkgs.coreutils}/bin/cp /tmp/detsys-vault/paperless.pass /var/lib/vault/paperless.pass";
        ExecStartPost =
          "${pkgs.coreutils}/bin/chown paperless:paperless /var/lib/vault/paperless.pass"; # Change file ownership to vaultwarden
      };
      wantedBy = [ "multi-user.target" ];
      before = [ "paperless.service" ];
    };

    virtualisation.oci-containers.containers.gotenberg = {
      user = "gotenberg:gotenberg";
      image = "gotenberg/gotenberg:7.8.1";

      cmd = [
        "gotenberg"
        "--chromium-disable-javascript=true"
        "--chromium-allow-list=file:///tmp/.*"
      ];

      ports = [ "127.0.0.1:${cfg.gotenbergPort}:3000" ];
    };

    virtualisation.oci-containers.containers.tika = {
      image = "apache/tika:2.4.0";

      ports = [ "127.0.0.1:${cfg.tikaPort}:9998" ];
    };

    excalibur.services.vault-agent.services.paperlessPasswordFile = {
      settings = {
        vault.address = cfg.vault-address;
        auto_auth = {
          method = [{
            type = "approle";
            config = {
              role_id_file_path = cfg.role-id;
              secret_id_file_path = cfg.secret-id;
              remove_secret_id_file_after_reading = false;
            };
          }];
        };
      };
      secrets = {
        file = {
          files = {
            "paperless.pass" = {
              text = ''
                {{ with secret "${cfg.vault-path}" }}{{ if eq "${cfg.kvVersion}" "v1" }}{{ .Data.password }}{{ else }}{{ .Data.data.password }}{{ end }}{{ end }}'';
              permissions = "0600";
              change-action = "restart";
            };
          };
        };
      };
    };
  };
}
