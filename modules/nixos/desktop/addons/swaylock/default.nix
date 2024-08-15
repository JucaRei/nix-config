{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.desktop.addons.swaylock;
in {
  options.excalibur.desktop.addons.swaylock = with types; {
    enable = mkBoolOpt false "Swaylock fix so it works with pam";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [swaylock-effects];
    security.pam.services.swaylock = {};
  };
}
