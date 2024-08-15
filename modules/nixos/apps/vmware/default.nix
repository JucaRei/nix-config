{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.apps.vmware;
in {
  options.excalibur.apps.vmware = with types; {
    enable = mkBoolOpt false "Whether or not to enable Firefox.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [vmware-workstation];
  };
}
