{ config
, lib
, options
, pkgs
, ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.desktop.display-manager.regreet;
  greetdSwayConfig = pkgs.writeText "greetd-sway-config" ''
    exec dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK
    exec systemctl --user import-environment

    ${cfg.swayOutput}

    input "type:touchpad" {
      tap enabled
    }


    xwayland disable

    bindsym XF86MonBrightnessUp exec light -A 5
    bindsym XF86MonBrightnessDown exec light -U 5
    bindsym Print exec ${getExe pkgs.grim} /tmp/regreet.png
    bindsym Mod4+shift+e exec ${
      getExe' config.programs.sway.package "swaynag"
    } \
      -t warning \
      -m 'What do you want to do?' \
      -b 'Poweroff' 'systemctl poweroff' \
      -b 'Reboot' 'systemctl reboot'

    exec "${getExe pkgs.greetd.regreet} -l debug; ${
      getExe' config.programs.sway.package "swaymsg"
    } exit"
  '';
in
{
  options.excalibur.desktop.display-manager.regreet = with types; {
    enable = mkBoolOpt false "Whether or not to enable greetd.";
    swayOutput = mkOpt lines "" "Sway Outputs config.";
    font = mkOpt types.str "MonaspiceNe Nerd Font" "Default font name";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      config.excalibur.desktop.addons.gtk.cursor.pkg
      config.excalibur.desktop.addons.gtk.icon.pkg
      config.excalibur.desktop.addons.gtk.theme.pkg
      pkgs.vulkan-validation-layers
    ];

    programs.regreet = {
      enable = true;

      settings = {
        # background = {
        #   path = pkgs.excalibur.wallpapers.flatppuccin_macchiato;
        #   fit = "Cover";
        # };

        GTK = {
          application_prefer_dark_theme = true;
          cursor_theme_name = "${config.excalibur.desktop.addons.gtk.cursor.name}";
          font_name = "${config.excalibur.system.fonts.default} * 12";
          icon_theme_name = "${config.excalibur.desktop.addons.gtk.icon.name}";
          theme_name = "${config.excalibur.desktop.addons.gtk.theme.name}";
        };
      };
    };

    services.greetd.settings.default_session = {
      command = "env GTK_USE_PORTAL=0 ${getExe pkgs.sway} --config ${greetdSwayConfig}";
    };

    security.pam.services.greetd = {
      enableGnomeKeyring = true;
      gnupg.enable = true;
    };
  };
}
