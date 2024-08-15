{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.tools.mangohud;
in {
  options.excalibur.tools.mangohud = with types; {
    enable = mkBoolOpt false "Whether or not to enable mangohud.";
  };

  config = mkIf cfg.enable {home.packages = with pkgs; [mangohud];};
}
