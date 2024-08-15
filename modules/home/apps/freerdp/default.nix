{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.excalibur.apps.freerdp;
in {
  options.excalibur.apps.freerdp = {enable = mkEnableOption "freerdp";};

  config = mkIf cfg.enable {home.packages = with pkgs; [freerdp];};
}
