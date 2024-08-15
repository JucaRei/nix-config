{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.tools.go;
in {
  options.excalibur.tools.go = with types; {
    enable = mkBoolOpt false "Whether or not to enable Go support.";
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [go gopls];
      sessionVariables = {GOPATH = "$HOME/work/go";};
    };
  };
}
