{ options
, config
, lib
, ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.apps.onepass;
in
{
  options.excalibur.apps.onepass = with types; {
    enable =
      mkBoolOpt false
        "Whether or not to enable 1Password with polkitPolicyOwners.";
  };

  config = mkIf cfg.enable {
    programs = {
      _1password-gui = {
        enable = true;
        polkitPolicyOwners = [ config.excalibur.user.name ];
      };
    };
  };
}
