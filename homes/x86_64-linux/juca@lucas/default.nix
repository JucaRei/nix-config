{ lib, pkgs, config, osConfig ? { }, format ? "unknown", ... }:
with lib.excalibur; {
  excalibur = {
    user = {
      enable = true;
      name = "mcamp";
      fullName = "Matt Camp";
      email = "matt@aiexcalibur.com";
    };
    desktop = {
      addons = {
        waynergy = enabled;
        rofi = enabled;
        swaynotificationcenter = enabled;
        networkmanagerapplet = enabled;
        swayidle = enabled;
        swaylock = enabled;
        input-leap = enabled;
        qt = enabled;
        kitty = enabled;
        waybar = {
          enable = true;
          display = "HDMI-A-3";
        };
        hyprpaper = {
          enable = true;
          monitors = [
            {
              name = "HDMI-A-1";
              wallpaper =
                "${pkgs.excalibur.wallpapers}/share/wallpapers/hsv-saturnV.jpg";
            }
            {
              name = "HDMI-A-2";
              wallpaper =
                "${pkgs.excalibur.wallpapers}/share/wallpapers/hsv-saturnV.jpg";
            }
            {
              name = "HDMI-A-3";
              wallpaper =
                "${pkgs.excalibur.wallpapers}/share/wallpapers/hsv-saturnV.jpg";
            }
          ];

          wallpapers = [
            "${pkgs.excalibur.wallpapers}/share/wallpapers/hsv-saturnV.jpg"
          ];
        };
        gbar = enabled;
        wofi = enabled;
      };
      wallpapers = enabled;
      qtile = {
        enable = true;
        wallpaper = "hsv-saturnV.jpg";
      };
      hyprland = {
        enable = true;
        # startup = [ "${getExe pkgs.ckb-next} -b" ];
      };
    };

    cli = {
      zsh = enabled;
      bash = enabled;
      env = enabled;
      home-manager = enabled;
      k9s = enabled;
      broot = enabled;
      ranger = enabled;
      neovim = enabled;
    };
    services = {
      # picom = enabled;
      openssh = enabled;
      syncthing = enabled;
    };

    apps = {
      firefox = enabled;
      brave = enabled;
      # libreoffice = enabled;
      # alacritty = enabled;
      # kitty = enabled;
      # rofi = enabled;
      mpv = enabled;
      #TODO: Add Qutebrowser
    };
    tools = {
      git = enabled;
      direnv = enabled;
      scientific-fhs = enabled;
      # julia = enabled;
      # python = enabled;
      vault = enabled;
    };
  };

  home.stateVersion = "23.05";
}
