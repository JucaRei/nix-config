{ lib
, config
, ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.excalibur.apps.mpv;
in
{
  options.excalibur.apps.mpv = { enable = mkEnableOption "mpv"; };

  config = mkIf cfg.enable { programs.mpv = { enable = true; }; };
}
