{ lib
, config
, pkgs
, ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.excalibur.cli.spacevim;
in
{
  options.excalibur.cli.spacevim = { enable = mkEnableOption "Neovim"; };

  config =
    mkIf cfg.enable { home = { packages = with pkgs; [ less spacevim ]; }; };
}
