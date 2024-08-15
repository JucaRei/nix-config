{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.apps.compose2nix;
in {
  options.excalibur.apps.compose2nix = with types; {
    enable = mkBoolOpt false "Whether or not to enable Compose2Nix.";
  };

  config = mkIf cfg.enable {home.packages = with pkgs; [compose2nix];};
}
