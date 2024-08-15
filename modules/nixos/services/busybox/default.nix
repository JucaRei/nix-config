{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.services.busybox;
in {
  options.excalibur.services.busybox = with types; {
    enable = mkBoolOpt false "Enable busybox;";
  };

  config =
    mkIf cfg.enable {environment.systemPackages = with pkgs; [busybox];};
}
