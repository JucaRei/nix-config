{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.apps.minecraft;
in {
  options.excalibur.apps.minecraft = with types; {
    enable = mkBoolOpt false "Whether or not to enable minecraft.";
  };

  config = mkIf cfg.enable {home.packages = with pkgs; [minecraft];};
}
