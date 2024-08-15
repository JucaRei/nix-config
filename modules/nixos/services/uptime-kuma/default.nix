{ lib
, config
, ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.services.uptime-kuma;
in
{
  options.excalibur.services.uptime-kuma = with types; {
    enable = mkBoolOpt false "Enable an Searx;";
    port = mkOpt int 4000 "Port to Host the uptime-kuma server on.";
  };

  config = mkIf cfg.enable {
    services.uptime-kuma = {
      enable = true;
      appriseSupport = true;
      settings = {
        PORT = "${toString cfg.port}";
        HOST = "0.0.0.0";
      };
    };
  };
}
