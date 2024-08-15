{ options, config, lib, pkgs, ... }:
with lib;
with lib.excalibur;
let
  cfg = config.excalibur.desktop.qtile;

  # TODO: Look at renaming.. figure this oculd be used to put gui apps that make qtile config pretty and what not
  defaultExtensions = with pkgs; [ networkmanagerapplet arc-theme ];
in
{
  options.excalibur.desktop.qtile = with types; {
    enable =
      mkBoolOpt false "Whether or not to use Qtile as the desktop environment.";
  };

  config = mkIf cfg.enable {
    excalibur.system.xkb.enable = true;
    excalibur.desktop.addons = { wallpapers = enabled; };

    environment.systemPackages = with pkgs;
      [
        gtk4
        qtile
        rofi
        xclip
        xsel
        feh
        dunst
        autorandr
        arandr
        go-sct
        brightnessctl
      ] ++ defaultExtensions;

    services.udev.packages = with pkgs; [ ];
    services.picom.enable = true;
    services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
      [org.gnome.desktop.interface]
      gtk-theme='Arc-Dark'
    '';
    environment.etc =
      let rofiThemes = "${pkgs.rofi}/share/rofi/themes";
      in mapAttrs'
        (name: _: {
          name = "rofi/themes/${name}";
          value = { source = "${rofiThemes}/${name}"; };
        })
        (builtins.readDir rofiThemes);

    services.libinput.enable = true;
    services.xserver = {
      enable = true;
      windowManager.qtile = {
        enable = true;
        # extraPackages = python3Packages: with python3Packages; [
        #   qtile-extras
        # ];
      };
    };
    excalibur.home.extraOptions = { };

    # Open firewall for samba connections to work.
    # networking.firewall.extraCommands =
    #   "iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns";
  };
}
