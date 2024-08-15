{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.apps.mattermost-desktop;
in {
  options.excalibur.apps.mattermost-desktop = with types; {
    enable =
      mkBoolOpt false "Whether or not to enable Mattermost Desktop Client.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [mattermost-desktop];
  };
}
