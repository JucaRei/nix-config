{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.tools.emoji-picker;
  inherit (pkgs.excalibur) emoji-picker;
in {
  options.excalibur.tools.emoji-picker = with types; {
    enable = mkBoolOpt false "Whether or not to enable emoji-picker.";
  };
  config = mkIf cfg.enable {home.packages = with pkgs; [emoji-picker];};
}
