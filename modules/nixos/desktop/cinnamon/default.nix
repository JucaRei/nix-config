{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.desktop.cinnamon;
in {
  options.excalibur.desktop.cinnamon = with types; {
    enable =
      mkBoolOpt false "Whether or not to use Gnome as the desktop environment.";
    suspend =
      mkBoolOpt false "Whether or not to suspend the machine after inactivity.";
    monitors = mkOpt (nullOr path) null "The monitors.xml file to create.";
  };

  config = mkIf cfg.enable {
    excalibur.system.xkb.enable = true;
    excalibur.desktop.addons = {
      #      gtk = enabled;
      wallpapers = enabled;
      #      electron-support = enabled;
      #      foot = enabled;
    };

    environment.systemPackages = with pkgs; [
      wl-clipboard
      gnome.gnome-tweaks
      gnome.nautilus-python
    ];

    environment.gnome.excludePackages = with pkgs.gnome; [
      pkgs.gnome-tour
      epiphany
      geary
      gnome-font-viewer
      gnome-system-monitor
      gnome-maps
    ];

    #    systemd.tmpfiles.rules = [
    #      "d ${gdmHome}/.config 0711 gdm gdm"
    #    ] ++ (
    #      # "./monitors.xml" comes from ~/.config/monitors.xml when GNOME
    #      # display information is updated.
    #      lib.optional (cfg.monitors != null) "L+ ${gdmHome}/.config/monitors.xml - - - - ${cfg.monitors}"
    #    );

    systemd.services.excalibur-user-icon = {
      before = ["display-manager.service"];
      wantedBy = ["display-manager.service"];

      serviceConfig = {
        Type = "simple";
        User = "root";
        Group = "root";
      };

      script = ''
        config_file=/var/lib/AccountsService/users/${config.excalibur.user.name}
        icon_file=/run/current-system/sw/share/excalibur-icons/user/${config.excalibur.user.name}/${config.excalibur.user.icon.fileName}

        if ! [ -d "$(dirname "$config_file")"]; then
          mkdir -p "$(dirname "$config_file")"
        fi

        if ! [ -f "$config_file" ]; then
          echo "[User]
          Session=gnome
          SystemAccount=false
          Icon=$icon_file" > "$config_file"
        else
          icon_config=$(sed -E -n -e "/Icon=.*/p" $config_file)

          if [[ "$icon_config" == "" ]]; then
            echo "Icon=$icon_file" >> $config_file
          else
            sed -E -i -e "s#^Icon=.*$#Icon=$icon_file#" $config_file
          fi
        fi
      '';
    };

    services.xserver = {
      enable = true;
      libinput.enable = true;
      desktopManager.cinnamon = {enable = true;};
    };

    programs.kdeconnect = {
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };
  };
}
