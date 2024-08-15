{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.tools.node;
in {
  options.excalibur.tools.node = with types; {
    enable = mkBoolOpt false "Whether or not to enable common Node.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [nodejs yarn];
  };
}
