{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.excalibur.apps.zoom;
in {
  options.excalibur.apps.zoom = {enable = mkEnableOption "zoom";};

  config = mkIf cfg.enable {home.packages = with pkgs; [zoom-us];};
}
