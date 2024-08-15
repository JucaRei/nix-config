{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.services.postgresql;
in {
  options.excalibur.services.postgresql = with types; {
    enable = mkBoolOpt false "Enable PostgreSQL on a server";
    role-id =
      mkOpt str config.excalibur.services.vault-agent.settings.vault.role-id
      "Absolute path to the Vault role-id";
    secret-id =
      mkOpt str config.excalibur.services.vault-agent.settings.vault.secret-id
      "Absolute path to the Vault secret-id";
    vault-path =
      mkOpt str "secret/excalibur/database-users"
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
    databases = mkOption {
      type = listOf (submodule {
        options = {
          name = mkOption {
            type = str;
            description = "Database name";
          };
          user = mkOption {
            type = str;
            description = "User who should have full access to the database";
          };
        };
      });
      description = "Databases to initialize, along with a privileged user for each.";
    };
    package = mkOpt package pkgs.postgresql_16 "What PostgreSQL to use";
    enableTCPIP = mkBoolOpt false "Enable TCP access";
    authentication = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "# Allow only local connections for the root user"
        "local all root trust"
        "local all postgres peer"
        "# Require password for Vault-generated users over the network"
        "host  all  all  10.8.0.1/24  md5"
        "# Deny other remote connections"
        "host  all  all  0.0.0.0/0  reject"
        "host  all  all  ::0/0  reject"
      ];
      description = "Authentication settings for PostgreSQL";
    };
    identMap = mkOption {
      type = lib.types.lines;
      default = "";
      example = ''
        map-name-0 system-username-0 database-username-0
        map-name-1 system-username-1 database-username-1
      '';
      description = lib.mdDoc ''
        Defines the mapping from system users to database users.

        See the [auth doc](https://postgresql.org/docs/current/auth-username-maps.html).
      '';
    };
    extraInit = mkOpt str "" "Extra stuff to put into the Init script";
    extraPlugins = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [pkgs.postgresql16Packages.timescaledb];
      description = "A list of packages to use.";
    };
    backupEnable = mkBoolOpt false "Enable backups";
    backupLocation = mkOpt str "/persist/db-backups/" "Place to store backups";
    backupStartAt = mkOpt str "*-*-* 01:15:00" "Time to start backups";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [5432]; # Open PostgreSQL port
    services.postgresql = {
      enable = true;
      package = cfg.package;
      extraPlugins = cfg.extraPlugins;
      enableTCPIP = cfg.enableTCPIP;
      authentication = lib.concatStringsSep "\n"  cfg.authentication;
      ensureDatabases = map (db: db.name) cfg.databases;
      ensureUsers =
        map (db: {
          name = db.user;
          ensureDBOwnership = true;
          # ensurePermissions = {
          #   "DATABASE ${db.name}" = "ALL PRIVILEGES";
          # };
          ensureClauses = {
            login = true; # or however you wish to set this
          };
        })
        cfg.databases;
    };
    services.postgresqlBackup = {
      enable = cfg.backupEnable;
      location = cfg.backupLocation;
      startAt = cfg.backupStartAt;
      databases = map (db: db.name) cfg.databases;
    };

    systemd.services.set-postgres-passwords = {
      description = "Set PostgreSQL user passwords";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.postgresql}/bin/psql -f /tmp/detsys-vault/set-passwords.sql";
        User = "postgres";
      };
      after = ["postgresql.service"];
      wantedBy = ["multi-user.target"];
      preStart = "echo 'Preparing to set PostgreSQL passwords'";
    };

    excalibur.services.vault-agent.services.set-postgres-passwords = {
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
            "set-passwords.sql" = {
              text = builtins.concatStringsSep "\n" (map (db: ''
                  {{ with secret "${cfg.vault-path}" }}
                  ALTER USER ${db.user} WITH PASSWORD '{{ if eq "${cfg.kvVersion}" "v1" }}{{ .Data.${db.user} }}{{ else }}{{ .Data.data.${db.user} }}{{ end }}';
                  {{ end }}
                '')
                cfg.databases);
              permissions = "0600";
              change-action = "restart";
            };
          };
        };
      };
    };
  };
}
