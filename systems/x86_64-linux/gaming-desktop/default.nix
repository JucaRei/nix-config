{ pkgs, lib, nixos-hardware, nixosModules, agenix, config, ... }:
with lib;
with lib.excalibur;
let
  newUser = name: {
    isNormalUser = true;
    createHome = true;
    home = "/home/${name}";
    shell = pkgs.zsh;
  };
in
{
  imports = [ ./hardware.nix ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  excalibur = {
    user = {
      name = "juca";
      fullName = "Reinaldo P Jr";
      email = "reinaldo800@gmail.com";
      initialPassword = "password";
      extraGroups = [ "wheel" ];
    };
    archetypes = {
      gaming-platform = enabled;
    };

    hardware = {
      nvidia = {
        enable = true;
        driverType = "beta";
      };
    };

    apps = {
      onepass = enabled;
    };

    system = {
      boot = enabled;
    };
  };

  excalibur.tools = {
    appimage = enabled;
    noisetorch = enabled;
  };

  excalibur.services = { };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
