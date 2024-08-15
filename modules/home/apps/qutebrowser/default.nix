{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.excalibur.apps.qutebrowser;
  dir = ./qutebrowser;
in {
  options.excalibur.apps.qutebrowser = {
    enable = mkEnableOption "qutebrowser";
  };

  config = mkIf cfg.enable {
    home.file = lib.attrsets.listToAttrs (lib.attrsets.mapAttrsToList
      (name: _: {
        name = ".config/qutebrowser/${name}";
        value = {source = "${dir}/${name}";};
      }) (builtins.readDir dir));
    home.packages = with pkgs; [qutebrowser];
  };
}
