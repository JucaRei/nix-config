{ options
, config
, lib
, ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.hardware.networking;
in
{
  options.excalibur.hardware.networking = with types; {
    enable = mkBoolOpt false "Whether or not to enable networking support";
    hosts =
      mkOpt attrs { }
        "An attribute set to merge with <option>networking.hosts</option>";
  };

  config = mkIf cfg.enable {
    excalibur.user.extraGroups = [ "networkmanager" ];

    networking = {
      hosts =
        {
          "127.0.0.1" = [ "local.test" ] ++ (cfg.hosts."127.0.0.1" or [ ]);
        }
        // cfg.hosts;

      networkmanager = {
        enable = true;
        dhcp = "internal";
      };
    };

    # TODO: Figure this out cause if its on jupyter is not accessible
    networking.firewall = { enable = false; };
    # Fixes an issue that normally causes nixos-rebuild to fail.
    # https://github.com/NixOS/nixpkgs/issues/180175
    systemd.services.NetworkManager-wait-online.enable = false;
  };
}
