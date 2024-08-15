{ config, lib, options, pkgs, system, ... }:
with lib;
with lib.excalibur;
let
  # inherit (inputs) hyprland;
  # inherit (inputs) nixpkgs-wayland;
  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gesettings/schemas/${schema.name}";
    in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      gnome_schema=org.gnome.desktop.interface
      gesettings set $gnome_schema gtk-theme 'Adwaita'
    '';
  };
  dbus-hyprland-environment = pkgs.writeTextFile {
    name = "dbus-hyprland-environment";
    destination = "/bin/dbus-hyprland-environment";
    executable = true;

    text = ''
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=hyprland
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };
  cfg = config.excalibur.desktop.hyprland;
  programs = lib.makeBinPath [ config.programs.hyprland.package ];
in {
  options.excalibur.desktop.hyprland = with types; {
    enable = mkBoolOpt false "Whether or not to enable Hyprland.";
    customConfigFiles = mkOpt attrs { }
      "Custom configuration files that can be used to override the default files.";
    customFiles = mkOpt attrs { }
      "Custom files that can be used to override the default files.";
    wallpaper = mkOpt (nullOr package) null "The wallpaper to display.";
  };

  config = mkIf cfg.enable {
    excalibur.desktop.addons.swaylock.enable = true;
    excalibur.apps = {
      gamemode = {
        startscript =
          # bash
          ''
            ${getExe pkgs.libnotify} 'GameMode started'
            export PATH=$PATH:${programs}
            export HYPRLAND_INSTANCE_SIGNATURE=$(ls -1 /tmp/hypr | tail -1)
            ${
              getExe' hyprland.packages.${system}.hyprland "hyprctl"
            } --batch 'keyword decoration:blur 0 ; keyword animations:enabled 0 ; keyword misc:no_vfr 1'
          '';

        endscript =
          # bash
          ''
            ${getExe pkgs.libnotify} 'GameMode stopped'
            export PATH=$PATH:${programs}
            export HYPRLAND_INSTANCE_SIGNATURE=$(ls -1 /tmp/hypr | tail -1)
            ${
              getExe' hyprland.packages.${system}.hyprland "hyprctl"
            } --batch 'keyword decoration:blur 1 ; keyword animations:enabled 1 ; keyword misc:no_vfr 0'
          '';
      };
    };
    environment.sessionVariables = {
      CLUTTER_BACKEND = "wayland";
      GDK_BACKEND = "wayland,x11";
      HYPRLAND_LOG_WLR = "1";
      MOZ_ENABLE_WAYLAND = "1";
      XKB_DEFAULT_OPTIONS = "caps:escape";
      MOZ_USE_XINPUT2 = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
      WLR_NO_HARDWARE_CURSORS = "1";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      SDL_VIDEODRIVER = "wayland";
      WLR_DRM_NO_ATOMIC = "1";
      WLR_RENDERER = "vulkan";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      NIXOS_OZONE_WL = "1";
      _JAVA_AWT_WM_NONEREPARENTING = "1";
      __GL_GSYNC_ALLOWED = "0";
      __GL_VRR_ALLOWED = "0";
      GTK_USE_PORTAL = "1";
    };

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals =
        [ pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk ];
      config.common.default = [
        "gtk"
        "hyprland"
      ];
    };

    # For GTK applications, if needed
    environment.systemPackages = with pkgs; [
      hyprpaper
      cliphist
      swayimg
      wdisplays
      # nixpkgs-wayland.packages.${system}.wdisplays
      wl-screenrec
      wl-clipboard
      # nixpkgs-wayland.packages.${system}.wl-clipboard
      wlr-randr
      # Not really wayland specific, but I don't want to make a new module for it
      brightnessctl
      glib # for gsettings
      gtk3.out # for gtk-launch
      playerctl
      dbus-hyprland-environment
      configure-gtk
    ];
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      package = pkgs.hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
    };
  };
}
