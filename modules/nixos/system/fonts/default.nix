{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.system.fonts;
in {
  options.excalibur.system.fonts = with types; {
    enable = mkBoolOpt false "Whether or not to manage fonts.";
    fonts = mkOpt (listOf package) [] "Custom font packages to install.";
    default = mkOpt types.str "FiraCode" "Default font name";
  };

  config = mkIf cfg.enable {
    environment.variables = {
      # Enable icons in tooling since we have nerdfonts.
      LOG_ICONS = "true";
    };

    environment.systemPackages = with pkgs; [font-manager];
    # fonts.fonts = with pkgs;

    fonts.packages = with pkgs;
      [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
        noto-fonts-emoji
        hack-font
        font-awesome
        ibm-plex
        material-design-icons
        fira-mono
        dejavu_fonts
        fira-code-symbols
        (nerdfonts.override {fonts = ["Hack"];})
      ]
      ++ cfg.fonts;
  };
}
