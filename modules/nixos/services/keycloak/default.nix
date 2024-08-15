{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.services.keycloak;
in {
  options.excalibur.services.keycloak = with types; {
    enable = mkBoolOpt false "Whether or not to enable keycloak.";
    port = mkOpt int 19323 "Port to listen on";
    domain =
      mkOpt str "keycloak.lan.aiexcalibur.com"
      "The domain part of the public URL used as base for all frontend requests.";

    role-id =
      mkOpt str config.excalibur.services.vault-agent.settings.vault.role-id
      "Absolute path to the Vault role-id";
    secret-id =
      mkOpt str config.excalibur.services.vault-agent.settings.vault.secret-id
      "Absolute path to the Vault secret-id";
    vault-path =
      mkOpt str "secret/excalibur/keycloak"
      "The Vault path to the KV containing the KVs that are for each database";
    kvVersion = mkOption {
      type = enum ["v1" "v2"];
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
    users = {
      users = {
        keycloak = {
          group = "keycloak";
          isSystemUser = true;
        };
      };
      groups = {keycloak = {};};
    };

    systemd.services.keycloakPasswordFile = {
      description = "Create Keycloak db password file";
      serviceConfig = {
        Type = "oneshot";
        User = "root"; # Use the root user to create the folder and set permissions
        ExecStartPre = "${pkgs.coreutils}/bin/chown root:root /var/lib/vault"; # Set folder ownership to root
        ExecStart = "${pkgs.coreutils}/bin/cp /tmp/detsys-vault/keycloak-db.pass /var/lib/vault/keycloak-db.pass";
        ExecStartPost = "${pkgs.coreutils}/bin/chown keycloak:keycloak /var/lib/vault/keycloak-db.pass"; # Change file ownership to vaultwarden
      };
      wantedBy = ["multi-user.target"];
      before = ["keycloakPostgreSQLInit.service" "keycloak.service"];
    };

    services.keycloak = {
      enable = true;

      database = {
        type = "postgresql";
        createLocally = true;
        username = "keycloak";
        passwordFile = "/var/lib/vault/keycloak-db.pass";
      };

      settings = {
        hostname = "keycloak.lan.aiexcalibur.com";
        hostname-admin-url = "https://keycloak.lan.aiexcalibur.com";
        http-port = cfg.port;
        http-host = "0.0.0.0";
        # hostname-strict-backchannel = true;
        proxy = "edge";
      };
      # themes = {
      #   keywind = pkgs.keycloak-keywind;
      # };
    };

    excalibur.services.postgresql = {
      enable = true;
      authentication = [
        "host keycloak keycloak 127.0.0.1/32 trust"
      ];
    };

    excalibur.services.vault-agent.services.keycloakPasswordFile = {
      settings = {
        vault.address = cfg.vault-address;
        auto_auth = {
          method = [
            {
              type = "approle";
              config = {
                role_id_file_path = cfg.role-id;
                secret_id_file_path = cfg.secret-id;
                remove_secret_id_file_after_reading = false;
              };
            }
          ];
        };
      };
      secrets = {
        file = {
          files = {
            "keycloak-db.pass" = {
              text = ''{{ with secret "${cfg.vault-path}" }}{{ if eq "${cfg.kvVersion}" "v1" }}{{ .Data.dbpass }}{{ else }}{{ .Data.data.dbpass }}{{ end }}{{ end }}'';
              permissions = "0600";
              change-action = "restart";
            };
          };
        };
      };
    };
  };
}
