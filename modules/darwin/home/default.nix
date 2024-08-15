{ options
, config
, lib
, ...
}:
with lib;
with lib.excalibur; {
  # imports = with inputs; [
  #   home-manager.darwinModules.home-manager
  # ];

  options.excalibur.home = with types; {
    file =
      mkOpt attrs { }
        "A set of files to be managed by home-manager's <option>home.file</option>.";
    configFile =
      mkOpt attrs { }
        "A set of files to be managed by home-manager's <option>xdg.configFile</option>.";
    extraOptions = mkOpt attrs { } "Options to pass directly to home-manager.";
    homeConfig = mkOpt attrs { } "Final config for home-manager.";
  };

  config = {
    excalibur.home.extraOptions = {
      home.stateVersion = config.system.stateVersion;
      home.file = mkAliasDefinitions options.excalibur.home.file;
      xdg.enable = true;
      xdg.configFile = mkAliasDefinitions options.excalibur.home.configFile;
    };

    snowfallorg.user.${config.excalibur.user.name}.home.config =
      mkAliasDefinitions options.excalibur.home.extraOptions;

    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;

      # users.${config.excalibur.user.name} = args:
      #   mkAliasDefinitions options.excalibur.home.extraOptions;
    };
  };
}
