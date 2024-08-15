{ lib
, config
, ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.services.file-share;
in
{
  options.excalibur.services.file-share = with types; {
    enable = mkBoolOpt false "Enable file-share;";
    port = mkOpt int 8380 "Port to listen on";
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;
      virtualHosts."localhost" = {
        listen = [
          {
            addr = "0.0.0.0";
            port = cfg.port;
          }
        ];
        root = "/export/share";
        locations."/".extraConfig = ''
          autoindex on;
        '';
      };
    };
  };
}
