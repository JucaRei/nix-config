{ lib
, config
, pkgs
, ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.services.vault;

  package =
    if cfg.ui
    then pkgs.vault-bin
    else pkgs.vault;

  has-policies = (builtins.length (builtins.attrNames cfg.policies)) != 0;

  format-policy = name: file:
    pkgs.runCommandNoCC "formatted-vault-policy"
      {
        inherit file;
        buildInputs = [ package ];
      } ''
      name="$(basename "$file")"

      cp "$file" "./$name"

      # Ensure that vault can overwrite the file.
      chmod +w "./$name"

      # Create this variable here to avoid swallowing vault's exit code.
      vault_output=

      set +e
      vault_output=$(vault policy fmt "./$name" 2>&1)
      vault_status=$?
      set -e

      if [ "$vault_status" != 0 ]; then
        echo 'Error formatting policy "${name}"'
        echo "This is normally caused by a syntax error in the policy file."
        echo "$file"
        echo ""
        echo "Vault Output:"
        echo "$vault_output"
        exit 1
      fi

      mv "./$name" $out
    '';

  policies = mapAttrs
    (name: value:
      if builtins.isPath value
      then format-policy name value
      else format-policy name (pkgs.writeText "${name}.hcl" value))
    cfg.policies;
in
{
  options.excalibur.services.vault = {
    enable = mkEnableOption "Vault";

    ui = mkBoolOpt true "Whether the UI should be enabled.";
    storage = {
      backend = mkOpt types.str "file" "The storage backend for Vault.";
      path = mkOpt types.str "/persist/vault" "Path";
    };

    address = mkOpt types.str "0.0.0.0:8200" "Where to access vault UI at";

    settings = mkOpt types.str "" "Configuration for Vault's config file.";

    mutable-policies =
      mkBoolOpt false
        "Whether policies not specified in Nix should be removed.";

    policies =
      mkOpt (types.attrsOf (types.either types.str types.path)) { }
        "Policies to install when Vault runs.";

    policy-agent = {
      user = mkOpt types.str "root" "The user to run the Vault Agent as.";
      group = mkOpt types.str "root" "The group to run the Vault Agent as.";

      auth = {
        roleIdFilePath =
          mkOpt types.str "/var/lib/vault/vault/role-id"
            "The file to read the role-id from.";
        secretIdFilePath =
          mkOpt types.str "/var/lib/vault/vault/secret-id"
            "The file to read the secret-id from.";
      };
    };
  };

  config = mkIf cfg.enable {
    services.vault = {
      enable = true;
      address = cfg.address;
      inherit package;
      storageBackend = cfg.storage.backend;
      storagePath = cfg.storage.path;
      extraConfig = ''
        ui = ${
          if cfg.ui
          then "true"
          else "false"
        }

        ${cfg.settings}
      '';
    };

    systemd.services.vault = { };

    # systemd.tmpfiles.rules =
    #   if cfg.storage.backend == "file" then [
    #     "d ${cfg.storage.path} 0750 vault vault -"
    #   ] else [];

    systemd.services.vault-policies = mkIf (has-policies || !cfg.mutable-policies) {
      wantedBy = [ "vault.service" ];
      after = [ "vault.service" ];

      serviceConfig = {
        Type = "oneshot";
        User = cfg.policy-agent.user;
        Group = cfg.policy-agent.group;
        Restart = "on-failure";
        RestartSec = 30;
        RemainAfterExit = "yes";
      };

      restartTriggers =
        mapAttrsToList (name: value: "${name}=${value}") policies;

      path = [ package pkgs.curl pkgs.jq ];

      environment = {
        VAULT_ADDR = "http://${config.services.vault.address}";
      };

      script =
        let
          write-policies-commands =
            mapAttrsToList
              (name: policy: ''
                echo Writing policy '${name}': '${policy}'
                vault policy write '${name}' '${policy}'
              '')
              policies;
          write-policies = concatStringsSep "\n" write-policies-commands;

          known-policies = mapAttrsToList (name: _value: name) policies;

          remove-unknown-policies = ''
            current_policies=$(vault policy list -format=json | jq -r '.[]')
            known_policies=(${
              concatStringsSep " "
              (builtins.map (policy: ''"${policy}"'') known-policies)
            })

            while read current_policy; do
              is_known=false

              for known_policy in "''${known_policies[@]}"; do
                if [ "$known_policy" = "$current_policy" ]; then
                  is_known=true
                  break
                fi
              done

              if [ "$is_known" = "false" ] && [ "$current_policy" != "default" ] && [ "$current_policy" != "root" ]; then
                echo "Removing policy: $current_policy"
                vault policy delete "$current_policy"
              else
                echo "Keeping policy: $current_policy"
              fi
            done <<< "$current_policies"
          '';
        in
        ''
          if ! [ -f '${cfg.policy-agent.auth.roleIdFilePath}' ]; then
            echo 'role-id file not found: ${cfg.policy-agent.auth.roleIdFilePath}'
            exit 0
          fi

          if ! [ -f '${cfg.policy-agent.auth.secretIdFilePath}' ]; then
            echo 'secret-id file not found: ${cfg.policy-agent.auth.secretIdFilePath}'
            exit 0
          fi

          role_id="$(cat '${cfg.policy-agent.auth.roleIdFilePath}')"
          secret_id="$(cat '${cfg.policy-agent.auth.secretIdFilePath}')"

          seal_status=$(curl -s "$VAULT_ADDR/v1/sys/seal-status" | jq ".sealed")

          echo "Seal Status: $seal_status"

          if [ seal_status = "true" ]; then
            echo "Vault is currently sealed, cannot install policies."
            exit 1
          fi

          echo "Getting token..."

          token=$(vault write -field=token auth/approle/login \
            role_id="$role_id" \
            secret_id="$secret_id" \
          )

          echo "Logging in..."

          export VAULT_TOKEN="$(vault login -method=token -token-only token="$token")"

          echo "Writing policies..."

          ${write-policies}

          ${optionalString (!cfg.mutable-policies) remove-unknown-policies}
          exit 0
        '';
    };
  };
}
