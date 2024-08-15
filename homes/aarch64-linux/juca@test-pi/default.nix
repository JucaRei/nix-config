{ lib, config, ... }:
with lib.excalibur; {
  excalibur = {
    user = {
      enable = true;
      name = config.snowfallorg.user.name;
    };

    cli = {
      zsh = enabled;
      home-manager = enabled;
    };
    tools = { git = enabled; };
  };
  home.stateVersion = "24.05";
}
