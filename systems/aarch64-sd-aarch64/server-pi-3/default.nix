{ pkgs, lib, modulesPath, inputs, ... }:
with lib;
with lib.excalibur; {
  imports = with inputs.nixos-hardware.nixosModules;
    [ (modulesPath + "/installer/scan/not-detected.nix") ];
  # sdImage.compressImage = false;
  # nixpkgs.config.allowUnsupportedSystem = true;
  # nixpkgs.crossSystem.system = "aarch64-linux";

  boot = { kernelPackages = pkgs.linuxKernel.packages.linux_rpi3; };

  excalibur = {
    user = {
      name = "juca";
      fullName = "Reinaldo P Jr";
      email = "reinaldo800@gmail.com";
      extraGroups = [ "wheel" "docker" ];
      uid = 10000;
    };
    # archetypes = {
    #   basic-pi = enabled;
    # };
    #
    # system = {
    #   boot = {
    #     # Raspberry Pi requires a specific bootloader.
    #     enable = mkForce false;
    #   };
    # };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
