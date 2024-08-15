{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.tools.nvim;
in {
  options.excalibur.tools.nvim = with types; {
    enable = mkBoolOpt false "Whether or not to enable common Neovim.";
  };

  config = mkIf cfg.enable {
    # TODO: Figure out maybe a better way to optionally use my nixvim.. but till then its mine or none
    environment.systemPackages = with pkgs; [excalibur.neovim];
  };
}
