{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.tools.pluto;
in {
  options.excalibur.tools.pluto = with types; {
    enable = mkBoolOpt false "Whether or not to enable common Pluto.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [excalibur.pluto];
  };
}
