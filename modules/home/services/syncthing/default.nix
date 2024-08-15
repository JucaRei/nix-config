{ options
, config
, lib
, ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.services.syncthing;
in
{
  options.excalibur.services.syncthing = with types; {
    enable = mkBoolOpt false "Whether or not to enable syncthing.";
  };

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      tray = { enable = false; };
      extraOptions = [ "--no-default-folder" ];
    };
  };
}
