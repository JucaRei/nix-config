{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.apps.lutris;
in {
  options.excalibur.apps.lutris = with types; {
    enable = mkBoolOpt false "Whether or not to enable lutris.";
  };

  config = mkIf cfg.enable {home.packages = with pkgs; [lutris];};
}
