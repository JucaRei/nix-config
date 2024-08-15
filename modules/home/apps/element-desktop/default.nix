{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.apps.element-desktop;
in {
  options.excalibur.apps.element-desktop = with types; {
    enable =
      mkBoolOpt false "Whether or not to enable Mattermost Desktop Client.";
    isWayland =
      mkBoolOpt config.excalibur.desktop.hyprland.enable
      "Insall wayland version";
  };

  config = mkIf cfg.enable {
    home.packages =
      lib.optional (!cfg.isWayland) pkgs.element-desktop
      ++ lib.optional cfg.isWayland pkgs.element-desktop-wayland;
  };
}
