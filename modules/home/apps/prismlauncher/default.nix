{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.apps.prismlauncher;
in {
  options.excalibur.apps.prismlauncher = with types; {
    enable = mkBoolOpt false "Whether or not to enable prismlauncher.";
  };

  config = mkIf cfg.enable {home.packages = with pkgs; [prismlauncher];};
}
