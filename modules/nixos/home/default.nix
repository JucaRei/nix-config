{ options
, config
, lib
, ...
}:
with lib;
with lib.excalibur; {
  # imports = with inputs; [
  #   home-manager.nixosModules.home-manager
  # ];

  options.excalibur.home = with types; {
    file =
      mkOpt attrs { }
        (mdDoc "A set of files to be managed by home-manager's `home.file`.");
    configFile =
      mkOpt attrs { } (mdDoc
        "A set of files to be managed by home-manager's `xdg.configFile`.");
    extraOptions = mkOpt attrs { } "Options to pass directly to home-manager.";
  };

  config = {
    excalibur.home.extraOptions = {
      home.stateVersion = config.system.stateVersion;
      home.file = mkAliasDefinitions options.excalibur.home.file;
      xdg.enable = true;
      xdg.configFile = mkAliasDefinitions options.excalibur.home.configFile;
    };

    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;

      users.${config.excalibur.user.name} =
        mkAliasDefinitions options.excalibur.home.extraOptions;
    };
  };
}
