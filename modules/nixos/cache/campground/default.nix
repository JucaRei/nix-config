{
  config,
  lib,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.cache.excalibur;
in {
  options.excalibur.cache.excalibur = {
    enable = mkEnableOption "excalibur cache";
  };
  config = mkIf cfg.enable {
    excalibur.nix.extra-substituters = {
      "https://attic.aiexcalibur.com/excalibur".key = "excalibur:XZ6LmOgWmChUUb5ZWWn/XnTreAYaNcPTQHxUR3T3dc8=";
    };
  };
}
