{ pkgs
, config
, lib
, nixos-hardware
, nixosModules
, ...
}:
with lib;
with lib.excalibur; let
  newUser = name: {
    isNormalUser = true;
    createHome = true;
    home = "/home/${name}";
    shell = pkgs.zsh;
  };
in
{
  imports = [ ./hardware.nix ];

  excalibur = {
    archetypes.barebones = enabled;

    system = {
      boot = enabled;
      zfs = {
        enable = true;
        hostId = "13ec383b"; # run -> head -c 8 /dev/machine-id
        keyfile-url = "http://10.8.0.1:1234/zfs-keyfile"; # optional for autounlocking
      };
      passwds = enabled;
    };

    user = {
      name = "juca";
      fullName = "Reinaldo P Jr";
      email = "head -c 8 /dev/machine-id";
      extraGroups = [ "wheel" ];
    };

    services = {
      openssh = {
        enable = true;
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGw+o+9F4kz+dYyI2I4WudgKjyFOK+L0QW4LhxkG4sMt gitlab-runner@aiexcalibur.com"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKdMWMFyi7Lvjm78KOX3tKZ5bkEZ7bHA56ZKKtTb9wIo mcamp@aiexcalibur.com"
        ];
      };
      ntp = enabled;
    };
  };

  system.stateVersion = "23.05";
}
