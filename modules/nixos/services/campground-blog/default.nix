{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with lib.excalibur;
let
  cfg = config.excalibur.services.excalibur-blog;
in
{
  options.excalibur.services.excalibur-blog = with types; {
    enable = mkBoolOpt false "Enable the excalibur Blog";
    port = mkOpt int 28345 "Port to host the Blog on";
    domain = mkOpt str "blog.aiexcalibur.com" "The Blog Domain";
  };

  config = mkIf cfg.enable {

    services.nginx = {
      enable = true;
      virtualHosts."${cfg.domain}" = {
        listen = [
          {
            addr = "0.0.0.0";
            port = cfg.port;
          }
        ];
        root = "${pkgs.excalibur.blog}/public";
        extraConfig = ''
          access_log /var/log/nginx/${cfg.domain}-access.log;
          error_log /var/log/nginx/${cfg.domain}-error.log;
          location / {
            try_files $uri $uri/ /index.html;
          }
          location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|ttf|woff|woff2|eot|otf)$ {
            try_files $uri $uri/ =404;
          }
        '';
      };
    };
  };
}
