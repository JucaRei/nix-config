{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.apps.webcord;
in {
  options.excalibur.apps.webcord = with types; {
    enable = mkBoolOpt false "Whether or not to enable webcord.";
  };

  config = mkIf cfg.enable {home.packages = with pkgs; [webcord];};
}
