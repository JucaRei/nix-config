{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.tools.protonup-qt;
in {
  options.excalibur.tools.protonup-qt = with types; {
    enable = mkBoolOpt false "Whether or not to enable protonup-qt.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [protonup-qt];
  };
}
