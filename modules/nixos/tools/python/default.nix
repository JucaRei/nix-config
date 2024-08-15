{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.tools.python;
in {
  options.excalibur.tools.python = with types; {
    enable = mkBoolOpt false "Whether or not to enable common Python.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [python];
  };
}
