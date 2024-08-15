{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.cli.broot;
in {
  options.excalibur.cli.broot = with types; {
    enable = mkBoolOpt false "Whether or not to enable broot.";
  };

  config = mkIf cfg.enable {home.packages = with pkgs; [broot];};
}
