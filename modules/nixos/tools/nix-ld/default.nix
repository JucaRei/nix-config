{ options
, config
, lib
, ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.tools.nix-ld;
in
{
  options.excalibur.tools.nix-ld = with types; {
    enable = mkBoolOpt false "Whether or not to enable nix-ld.";
  };

  config = mkIf cfg.enable { programs.nix-ld.enable = true; };
}
