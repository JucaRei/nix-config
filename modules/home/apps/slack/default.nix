{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.apps.slack;
in {
  options.excalibur.apps.slack = with types; {
    enable = mkBoolOpt false "Whether or not to enable Slack Desktop Client.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [slack];
  };
}
