{ options
, config
, lib
, ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.suites.development;
in
{
  options.excalibur.suites.development = with types; {
    enable =
      mkBoolOpt false
        "Whether or not to enable common development configuration.";
  };

  config = mkIf cfg.enable {
    excalibur = {
      apps = {
        k9s = enabled;
        virtmanager = enabled;
      };
      tools = {
        git = enabled;
        misc = enabled;
        # julia = enabled;
        # python = enabled;
      };
    };
  };
}
