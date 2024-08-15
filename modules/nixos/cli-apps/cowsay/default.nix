{ options
, config
, lib
, pkgs
, ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.cli-apps.cowsay;
in
{
  options.excalibur.cli-apps.cowsay = with types; {
    enable = mkBoolOpt false "Whether or not to enable cowsay.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ pkgs.cowsay ];
  };
}
