{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
with lib.excalibur;
let
  cfg = config.excalibur.services.matomo;
in
{
  options.excalibur.services.matomo = with types; {
    enable = mkBoolOpt false "Enable Matomo;";
    rootDomain = mkOpt str "aiexcalibur.com" "Root domain to use for Matomo";
  };

  config = mkIf cfg.enable {
    # TODO: Do better configign of this shit
    excalibur.services.mysql = {
      enable = true;
      databases = [
        {
          name = "matomo";
          user = "matomo";
        }
      ];
    };

    services.matomo = {
      enable = true;
      package = pkgs.matomo_5;
      hostname = cfg.rootDomain;
      nginx = {
        serverAliases = [
          "matomo.${cfg.rootDomain}"
          "stats.${cfg.rootDomain}"
        ];
        serverName = "matomo.${cfg.rootDomain}";
        listen = [
          {
            addr = "0.0.0.0";
            port = 16969; # Change this to your desired port
          }
        ];
        enableACME = false;
        forceSSL = false;

      };

    };

  };
}
