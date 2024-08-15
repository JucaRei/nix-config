{ options, config, lib, pkgs, ... }:
with lib;
with lib.excalibur;
let cfg = config.excalibur.tools.julia;
in {
  options.excalibur.tools.julia = with types; {
    enable = mkBoolOpt false "Whether or not to enable common Julia.";
  };

  config = mkIf cfg.enable { home.packages = with pkgs; [ excalibur.julia ]; };
}
