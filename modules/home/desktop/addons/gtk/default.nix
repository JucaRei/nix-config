{ options
, config
, lib
, pkgs
, ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.desktop.addons.gtk;
  default-attrs = mapAttrs (_key: mkDefault);
  nested-default-attrs = mapAttrs (_key: default-attrs);
in
{
  options.excalibur.desktop.addons.gtk = with types; {
    enable = mkBoolOpt false "Whether to customize GTK and apply themes.";
    cursor = {
      name =
        mkOpt str "Catppuccin-Macchiato-Blue-Cursors"
          "The name of the cursor theme to apply.";
      pkg =
        mkOpt package pkgs.catppuccin-cursors.macchiatoBlue
          "The package to use for the cursor theme.";
      size = mkOpt int 32 "The size of the cursor.";
    };
    icon = {
      name = mkOpt str "breeze-dark" "The name of the icon theme to apply.";
      pkg =
        mkOpt package pkgs.libsForQt5.breeze-icons
          "The package to use for the icon theme.";
    };
    theme = {
      name =
        mkOpt str "Catppuccin-Macchiato-Standard-Blue-Dark"
          "The name of the GTK theme to apply.";
      pkg = mkOpt package
        (pkgs.catppuccin-gtk.override {
          accents = [ "blue" ];
          size = "standard";
          variant = "macchiato";
        }) "The package to use for the theme.";
    };
  };
  config = mkIf cfg.enable {
    home.sessionVariables = {
      CURSOR_THEME = cfg.cursor.name;
      GTK_THEME = cfg.theme.name;
      XCURSOR_SIZE = "${toString cfg.cursor.size}";
      XCURSOR_THEME = cfg.cursor.name;
    };

    dconf = {
      enable = true;

      settings = nested-default-attrs {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          cursor-size = cfg.cursor.size;
          cursor-theme = cfg.cursor.name;
          enable-hot-corners = false;
          font-name = config.excalibur.system.fonts.default;
          gtk-theme = cfg.theme.name;
          icon-theme = cfg.icon.name;
        };
      };
    };

    gtk = {
      enable = true;

      cursorTheme = {
        inherit (cfg.cursor) name;
        package = cfg.cursor.pkg;
      };

      font = { name = config.excalibur.system.fonts.default; };

      gtk3.extraConfig = { "gtk-application-prefer-dark-theme" = 1; };

      gtk4.extraConfig = { "gtk-application-prefer-dark-theme" = 1; };

      iconTheme = {
        inherit (cfg.icon) name;
        package = cfg.icon.pkg;
      };

      theme = {
        inherit (cfg.theme) name;
        package = cfg.theme.pkg;
      };
    };

    home.pointerCursor = {
      inherit (cfg.cursor) name;
      inherit (cfg.cursor) size;
      package = cfg.cursor.pkg;
      gtk.enable = true;
      x11.enable = true;
    };
  };
}
