{ options
, config
, pkgs
, lib
, ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.tools.git;
  user = config.excalibur.user;
in
{
  options.excalibur.tools.git = with types; {
    enable = mkBoolOpt false "Whether or not to install and configure git.";
    userName = mkOpt types.str user.fullName "The name to configure git with.";
    userEmail = mkOpt types.str user.email "The email to configure git with.";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ git lazygit ];

    excalibur.home.extraOptions = {
      programs.git = {
        enable = true;
        userName = lib.mkForce cfg.userName;
        userEmail = lib.mkForce cfg.userEmail;
        lfs = enabled;
        extraConfig = {
          init = { defaultBranch = "main"; };
          pull = { rebase = true; };
          push = { autoSetupRemote = true; };
          core = { whitespace = "trailing-space,space-before-tab"; };
          safe = {
            directory = "${config.users.users.${user.name}.home}/work/config";
          };
        };
      };
    };
  };
}
