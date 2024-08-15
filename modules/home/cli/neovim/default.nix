{ lib
, config
, pkgs
, ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.excalibur.cli.neovim;
in
{
  options.excalibur.cli.neovim = { enable = mkEnableOption "Neovim"; };

  config = mkIf cfg.enable {
    home = { packages = with pkgs; [ less excalibur.neovim ]; };
  };
}
