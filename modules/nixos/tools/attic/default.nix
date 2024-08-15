{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.tools.attic;
in {
  options.excalibur.tools.attic = {enable = mkEnableOption "Attic";};

  config =
    mkIf cfg.enable {environment.systemPackages = with pkgs; [attic];};
}
