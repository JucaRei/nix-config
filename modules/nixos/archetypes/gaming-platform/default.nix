{ options
, config
, lib
, ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.archetypes.gaming-platform;
in
{
  options.excalibur.archetypes.gaming-platform = with types; {
    enable =
      mkBoolOpt false "Whether or not to enable the gaming-platform archetype.";
  };

  config = mkIf cfg.enable {
    excalibur = {
      suites = {
        common = enabled;
        desktop = enabled;
        gaming = enabled;
        # development = enabled;
        # art = enabled;
        # video = enabled;
        # social = enabled;
        # media = enabled;
      };

      # tools = {
      #   # appimage-run = enabled;
      # };
    };
  };
}
