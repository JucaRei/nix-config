{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.services.matt-camp-website;
in {
  options.excalibur.services.matt-camp-website = with types; {
    enable = mkBoolOpt false "Enable matt-camp-website;";
    port = mkOpt int 4356 "Port to listen on";
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;
      virtualHosts."matt-camp.com" = {
        listen = [
          {
            addr = "0.0.0.0";
            port = cfg.port;
          }
        ];
        root = "${pkgs.excalibur.matt-camp-website}/libexec/matt-camp-website/deps/matt-camp-website/dist/spa";
        extraConfig = ''
          location / {
            try_files $uri $uri/ =404;
          }
        '';
      };
    };
  };
}
