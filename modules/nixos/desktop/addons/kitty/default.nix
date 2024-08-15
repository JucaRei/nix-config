{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.desktop.addons.kitty;
in {
  options.excalibur.desktop.addons.kitty = with types; {
    enable =
      mkBoolOpt false "Whether to enable Kitty in the desktop environment.";
  };

  config =
    mkIf cfg.enable {environment.systemPackages = with pkgs; [kitty];};
}
