{ lib
, config
, ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.excalibur.cli-apps.neovim;
in
{
  options.excalibur.cli-apps.neovim = { enable = mkEnableOption "Neovim"; };

  config = mkIf cfg.enable {
    # environment.systemPackages = with pkgs; [
    #   less
    # ];
  };
}
