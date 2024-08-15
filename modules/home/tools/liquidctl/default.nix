{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.tools.liquidctl;
in {
  options.excalibur.tools.liquidctl = with types; {
    enable = mkBoolOpt false "Whether or not to enable common DVC.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [liquidctl];
  };
}
