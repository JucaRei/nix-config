{ options, config, lib, pkgs, ... }:
with lib;
with lib.excalibur;
let cfg = config.excalibur.apps.virtualbox;
in {
  options.excalibur.apps.virtualbox = with types; {
    enable = mkBoolOpt false "Whether or not to enable Virtualbox.";
  };

  config = mkIf cfg.enable {
    virtualisation.virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
      headless = true;
    };
    virtualisation.virtualbox.guest.enable = true;
    excalibur.user.extraGroups = [ "vboxusers" ];
    environment.systemPackages = [ pkgs.virtualbox ];
  };
}
