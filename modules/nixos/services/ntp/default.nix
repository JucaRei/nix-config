{ lib
, config
, ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.services.ntp;
in
{
  options.excalibur.services.ntp = with types; {
    enable = mkBoolOpt false "Enable CAC Support;";
  };

  config = mkIf cfg.enable {
    # networking.timeServers = options.networking.timeServers.default ++ [ "0.arch.pool.ntp.org" ];
    services.ntp.enable = true;
  };
}
