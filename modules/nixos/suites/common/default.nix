{
  options,
  config,
  lib,
  ...
}:
with lib;
with lib.excalibur;
let
  cfg = config.excalibur.suites.common;
in
{
  options.excalibur.suites.common = with types; {
    enable = mkBoolOpt false "Whether or not to enable common configuration.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ ];

    excalibur = {
      nix = {
        enable = true;
      };

      cache = {
        public = enabled;
        excalibur = enabled;
      };

      cli-apps = {
        flake = enabled;
      };

      tools = {
        git = enabled;
        misc = enabled;
        nix-output-monitor = enabled;
        pluto = enabled;
      };

      hardware = {
        audio = enabled;
        networking = enabled;
      };

      services = {
        openssh = {
          enable = true;
          authorizedKeys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGw+o+9F4kz+dYyI2I4WudgKjyFOK+L0QW4LhxkG4sMt gitlab-runner@aiexcalibur.com"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKdMWMFyi7Lvjm78KOX3tKZ5bkEZ7bHA56ZKKtTb9wIo mcamp@aiexcalibur.com"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAclfREva2i4LsnBQPY3ZSsZzeuS5DGn11u0abBR8cFv mcamp@butler"

          ];
        };
      };

      security = {
        keyring = enabled;
      };

      system = {
        boot = enabled;
        fonts = enabled;
        locale = enabled;
        time = enabled;
        xkb = enabled;
      };
    };
  };
}
