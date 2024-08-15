{ lib
, config
, ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.services.hydra;
in
{
  options.excalibur.services.hydra = with types; {
    enable = mkBoolOpt false "Enable an Searx;";
    port = mkOpt int 6956 "Port to Host the hydra server on.";
    # role-id = mkOpt str config.excalibur.services.vault-agent.settings.vault.role-id "Absolute path to the Vault role-id";
    # secret-id = mkOpt str config.excalibur.services.vault-agent.settings.vault.secret-id "Absolute path to the Vault secret-id";
    # vault-path = mkOpt str "secret/excalibur/hydra" "The Vault path to the KV containing the Searx Secrets.";
    # kvVersion = mkOption {
    #   type = enum ["v1" "v2"];
    #   default = "v2";
    #   description = "KV store version";
    # };
    # vault-address = mkOption {
    #   type = str;
    #   default = config.excalibur.services.vault-agent.settings.vault.address;
    #   description = "The address of your Vault";
    # };
  };

  config = mkIf cfg.enable {
    services.hydra = {
      enable = true;
      port = cfg.port;
      hydraURL = "https://hydra.lan.aiexcalibur.com";
      notificationSender = "hydra@aiexcalibur.com";
      buildMachinesFiles = [ ];
      useSubstitutes = true;
    };
  };
}
