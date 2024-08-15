{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.apps.barrier;
in {
  options.excalibur.apps.barrier = with types; {
    enable = mkBoolOpt false "Whether or not to enable barrier.";
  };

  config =
    mkIf cfg.enable {environment.systemPackages = with pkgs; [barrier];};
}
