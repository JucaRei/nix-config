{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.tools.misc;
in {
  options.excalibur.tools.misc = with types; {
    enable = mkBoolOpt false "Whether or not to enable common utilities.";
  };

  config = mkIf cfg.enable {
    excalibur.home.configFile."wgetrc".text = "";

    environment.systemPackages = with pkgs; [
      fzf
      killall
      unzip
      file
      jq
      clac
      wget
      ripgrep
      bat
      ranger
      lsd
      git
      rsync
      tldr
      gcc
      clang
      zig
      btop
      deno
      zathura
      flameshot
      neovim
      devour
      usbutils
      pciutils
      neofetch
      libnotify
      sbomnix
      bash
      lsof
      hwinfo
      traceroute
      gptfdisk
      parted
      tmux
      cntr
      glibc
      smartmontools
      lshw
      borgbackup
      yt-dlp
    ];
  };
}
