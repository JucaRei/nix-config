{ options
, config
, lib
, pkgs
, ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.desktop.addons.rkvm;
in
{
  options.excalibur.desktop.addons.rkvm = with types; {
    enable =
      mkBoolOpt false "Whether to enable rkvm in the desktop environment.";
  };
  config = mkIf cfg.enable { home.packages = [ pkgs.rkvm ]; };
}
