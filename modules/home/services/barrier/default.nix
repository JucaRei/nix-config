{
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf types;
  inherit (lib.internal) mkOpt;

  cfg = config.excalibur.services.barrier;
in {
  options.excalibur.services.barrier = {
    enable = mkEnableOption "barrier";
    server = mkOpt types.str "192.168.1.3:24800" "Server address";
  };

  config = mkIf cfg.enable {
    services = {
      barrier = {
        client = {
          enable = true;
          enableCrypto = true;
          enableDragDrop = true;

          inherit (cfg) server;
        };
      };
    };
  };
}
