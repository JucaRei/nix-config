{
  config,
  lib,
  options,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.desktop.addons.swappy;
in {
  options.excalibur.desktop.addons.swappy = {
    enable =
      mkBoolOpt false "Whether to enable Swappy in the desktop environment.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [swappy];

    excalibur.home = {
      configFile."swappy/config".source = ./config;
      file."Pictures/screenshots/.keep".text = "";
    };
  };
}
