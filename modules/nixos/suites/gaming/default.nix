{ options, config, lib, pkgs, ... }:
with lib;
with lib.excalibur;
let cfg = config.excalibur.suites.gaming;
in {
  options.excalibur.suites.gaming = with types; {
    enable = mkBoolOpt false "Whether or not to enable gaming configuration.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      [ pkgs.lutris pkgs.steam pkgs.prismlauncher pkgs.mangohud ];
  };
}
