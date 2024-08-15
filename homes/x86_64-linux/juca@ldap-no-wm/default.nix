{ lib
, pkgs
, config
, osConfig ? { }
, format ? "unknown"
, ...
}:
with lib.excalibur; {
  excalibur = {
    user = {
      enable = true;
      name = "juca";
      fullName = "Reinaldo P Jr";
      email = "reinaldo800@gmail.com";
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

    # apps = {
    #   firefox = enabled;
    #   brave = enabled;
    #   libreoffice = enabled;
    #   alacritty = enabled;
    #   kitty = enabled;
    #   rofi = enabled;
    #   mpv = enabled;
    #   #TODO: Add Qutebrowser
    # };
    tools = {
      git = enabled;
      direnv = enabled;
      # julia = enabled;
      # python = enabled;
      vault = enabled;
    };
  };

  home.stateVersion = "23.05";
}
