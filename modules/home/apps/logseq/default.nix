{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.excalibur.apps.logseq;
in {
  options.excalibur.apps.logseq = {enable = mkEnableOption "logseq";};

  config = mkIf cfg.enable {home.packages = with pkgs; [logseq];};
}
