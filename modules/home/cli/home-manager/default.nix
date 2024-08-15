{
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.excalibur) enabled;

  cfg = config.excalibur.cli.home-manager;
in {
  options.excalibur.cli.home-manager = {
    enable = mkEnableOption "home-manager";
  };

  config = mkIf cfg.enable {programs.home-manager = enabled;};
}
