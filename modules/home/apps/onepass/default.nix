{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.apps.onepass;
in {
  options.excalibur.apps.onepass = with types; {
    enable =
      mkBoolOpt false "Whether or not to enable 1Password and 1Password-cli.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [_1password-gui _1password];
  };
}
