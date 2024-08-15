{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.cli.k9s;
in {
  options.excalibur.cli.k9s = with types; {
    enable = mkBoolOpt false "Whether or not to enable K9s.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [k9s kubernetes-helm kubectl];
  };
}
