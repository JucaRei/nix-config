{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.excalibur.tools.icehouse;

  inherit (lib) mkEnableOption mkIf;
in {
  options.excalibur.tools.icehouse = {enable = mkEnableOption "Icehouse";};

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.snowfallorg.icehouse];
  };
}
