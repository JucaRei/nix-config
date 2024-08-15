{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.cli.misc;
in {
  options.excalibur.cli.misc = with types; {
    enable = mkBoolOpt false "Whether or not to misc cli programs.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      fzf
      killall
      unzip
      file
      jq
      clac
      wget
      ripgrep
      bat
      lsd
      rsync
      tldr
      gcc
      clang
      zig
      btop
      deno
      devour
      neovim
    ];
  };
}
