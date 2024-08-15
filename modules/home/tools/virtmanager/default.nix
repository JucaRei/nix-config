{ options
, config
, lib
, ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.tools.virtmanager;
in
{
  options.excalibur.tools.virtmanager = with types; {
    enable = mkBoolOpt false "Whether or not to enable Virt-manager.";
  };

  config = mkIf cfg.enable {
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu:///system" ];
        uris = [ "qemu:///system" ];
      };
    };
  };
}
