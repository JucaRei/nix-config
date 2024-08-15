{ options
, config
, lib
, pkgs
, ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.desktop.addons.input-leap;
in
{
  options.excalibur.desktop.addons.input-leap = with types; {
    enable =
      mkBoolOpt false
        "Whether to enable input-leap in the desktop environment.";
  };
  config = mkIf cfg.enable { home.packages = [ pkgs.input-leap ]; };
}
