{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.desktop.addons.swaynotificationcenter;
  swayncConfig = import ./config.nix {inherit pkgs;};
  swayncConfigFile = pkgs.writeTextFile {
    name = "swaync-config.json";
    text = builtins.toJSON swayncConfig;
  };
in {
  options.excalibur.desktop.addons.swaynotificationcenter = {
    enable = mkEnableOption "Hyprpaper";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [swaynotificationcenter libnotify];
    home.file.".config/swaync/config.json".source =
      lib.cleanSource swayncConfigFile;
    home.file.".config/swaync/style.css".source = ./config/style.css;
    home.file.".config/swaync/catppuccin.css".source = ./config/catppuccin.css;
  };
}
