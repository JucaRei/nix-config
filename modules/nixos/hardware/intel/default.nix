{ options
, config
, lib
, ...
}:
with lib; let
  cfg = config.excalibur.hardware.intel;
in
{
  options.excalibur.hardware.intel = with types; {
    enable = mkEnableOption "Intel Graphics";
  };

  config = mkIf cfg.enable {
    # services.xserver.videoDrivers = [ "intel" ];
  };
}
