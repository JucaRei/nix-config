{ options
, config
, lib
, pkgs
, ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.desktop.addons.networkmanagerapplet;
in
{
  options.excalibur.desktop.addons.networkmanagerapplet = with types; {
    enable =
      mkBoolOpt false
        "Whether to enable networkmanagerapplet in the desktop environment.";
  };
  config = mkIf cfg.enable { home.packages = [ pkgs.networkmanagerapplet ]; };
}
