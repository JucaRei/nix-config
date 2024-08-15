{ options, config, lib, pkgs, ... }:
with lib;
with lib.excalibur;
let cfg = config.excalibur.apps.thunderbird;
in {
  options.excalibur.apps.thunderbird = with types; {
    enable = mkBoolOpt false "Whether or not to enable Thunderbird for email.";
  };

  config = mkIf cfg.enable {
    programs.thunderbird.enable = true;
    programs.thunderbird.profiles.default = {
      isDefault = true;
      settings = { };
    };
  };
}
