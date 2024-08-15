{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.desktop.addons.wofi;
in {
  options.excalibur.desktop.addons.wofi = with types; {
    enable =
      mkBoolOpt false "Whether to enable the Wofi in the desktop environment.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [wofi wofi-emoji];

    excalibur.home.configFile = {
      "wofi/config".source = ./config;
      "wofi/style.css".source = ./style.css;
    };
  };
}
