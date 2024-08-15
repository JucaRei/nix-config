{ options
, config
, lib
, pkgs
, ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.cli.flake;
in
{
  options.excalibur.cli.flake = with types; {
    enable = mkBoolOpt false "Whether or not to enable flake.";
  };

  config =
    mkIf cfg.enable { home.packages = with pkgs; [ snowfallorg.flake ]; };
}
