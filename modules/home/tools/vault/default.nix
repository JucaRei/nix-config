{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.tools.vault;
in {
  options.excalibur.tools.vault = with types; {
    enable = mkBoolOpt false "Whether or not to enable common Vault CLI.";
    vault-addr =
      mkOpt str "https://vault.lan.aiexcalibur.com" "url for the vault";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [vault];
    home.sessionVariables = {VAULT_ADDR = cfg.vault-addr;};
  };
}
