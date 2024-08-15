{ options
, config
, lib
, ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.tools.noisetorch;
in
{
  options.excalibur.tools.noisetorch = with types; {
    enable = mkBoolOpt false "Whether or not to enable noisetorch.";
  };

  config = mkIf cfg.enable { programs.noisetorch.enable = true; };
}
