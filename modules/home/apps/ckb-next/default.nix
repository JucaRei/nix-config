{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.excalibur.apps.ckb-next;
in {
  options.excalibur.apps.ckb-next = {enable = mkEnableOption "ckb-next";};

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ckb-next];
    home.file = {".config/ckb-next/ckb-next.conf".source = ./ckb-next.conf;};
  };
}
