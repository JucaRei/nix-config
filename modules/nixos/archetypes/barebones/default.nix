{ options
, config
, lib
, ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.archetypes.barebones;
in
{
  options.excalibur.archetypes.barebones = with types; {
    enable =
      mkBoolOpt false "Whether or not to enable the barebones archetype.";
  };

  config =
    mkIf cfg.enable { excalibur = { suites = { common = enabled; }; }; };
}
