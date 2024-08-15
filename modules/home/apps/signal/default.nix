{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.apps.signal;
in {
  options.excalibur.apps.signal = with types; {
    enable = mkBoolOpt false "Whether or not to enable signal.";
  };

  config = mkIf cfg.enable {home.packages = with pkgs; [signal-desktop];};
}
