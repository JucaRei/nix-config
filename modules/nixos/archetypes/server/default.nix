{ options, config, lib, pkgs, ... }:
with lib;
with lib.excalibur;
let cfg = config.excalibur.archetypes.server;
in {
  options.excalibur.archetypes.server = with types; {
    enable = mkBoolOpt false "Whether or not to enable the server archetype.";
    k8s = mkBoolOpt false "Is this a K8s Node?";
    role = mkOption {
      type = types.enum [ "controller" "controller+worker" "worker" "single" ];
      default = "single";
      description = ''
        K8s role.
      '';
    };
    hostId = mkOpt str "" "ZFS Host ID";
    isLeader = mkBoolOpt false "Whether or not k0s leader";
  };

  config = mkIf cfg.enable {
    excalibur = {
      suites = {
        common = enabled;
        observability = enabled;
      };
      system = {
        zfs = {
          enable = true;
          hostId = cfg.hostId;
          keyfile-url = "http://10.8.0.55:8123/zfs-keyfile";
        };
        passwds = enabled;
      };
      services = {
        ntp = enabled;
        docker = enabled;
        ldap-client = enabled;
        tang = enabled;
        k0s = {
          enable = cfg.k8s;
          package = pkgs.excalibur.k0s;
          role = cfg.role;
          apiAddress = "10.8.0.1";
          apiSans = [ "daly" "ermy" "campnet" ];
          clusterName = "excalibur";
          isLeader = false; # Set this to true on the initial controller node
          dataDir = "/var/lib/k0s";
        };
        openssh = {
          authorizedKeys = [
            "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAGs9njLHA3yyrX6BTf5Z3Xj8jzOh9zVYfJoeai6WhmBtjr34KV0F79YKafvJPS4gasOTFpnKXObvBo0jG3/AIN+dwBohHtFtXSYBgZecFg847XoeN+7cIveqgI2Q1Jn2sFoUTzGiwKxqLRM7ZuTtRJGfoizOxlYHdyovus67jfDxewP5A== mcamp@Butler"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINLbrIDbLSEpfOc4onBP8y6aKCNEN5rEe0J3h7klfKzG mcamp@butler"
          ];
        };
      };
    };
  };
}
