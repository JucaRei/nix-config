{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.services.cac;
in {
  options.excalibur.services.cac = with types; {
    enable = mkBoolOpt false "Enable CAC Support;";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [pcsclite opensc ccid];

    services.pcscd.enable = true;
  };
}
