{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) types mkEnableOption mkIf;
  inherit (lib.excalibur) mkOpt enabled;

  cfg = config.excalibur.tools.git;
  user = config.excalibur.user;
in {
  options.excalibur.tools.git = {
    enable = mkEnableOption "Git";
    userName = mkOpt types.str user.fullName "The name to configure git with.";
    userEmail = mkOpt types.str user.email "The email to configure git with.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [lazygit];

    programs.git = {
      enable = true;
      userName = cfg.userName;
      userEmail = cfg.userEmail;
      ignores = ["result"];
      lfs = enabled;
      extraConfig = {
        init = {defaultBranch = "main";};
        pull = {rebase = true;};
        push = {autoSetupRemote = true;};
        core = {whitespace = "trailing-space,space-before-tab";};
        safe = {directory = "${user.home}/work/config";};
      };
    };
  };
}
