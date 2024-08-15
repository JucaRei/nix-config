{ options
, config
, lib
, pkgs
, ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.desktop.addons.waynergy;
in
{
  options.excalibur.desktop.addons.waynergy = with types; {
    enable =
      mkBoolOpt false "Whether to enable waynergy in the desktop environment.";
  };
  config = mkIf cfg.enable { home.packages = [ pkgs.waynergy ]; };
}
