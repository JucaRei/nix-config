{
  config,
  lib,
  options,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.desktop.addons.electron-support;
in {
  options.excalibur.desktop.addons.electron-support = {
    enable =
      mkBoolOpt false
      "Whether to enable electron support in the desktop environment.";
  };

  config = mkIf cfg.enable {
    environment.sessionVariables = {NIXOS_OZONE_WL = "1";};

    excalibur.home.configFile."electron-flags.conf".source =
      ./electron-flags.conf;
  };
}
