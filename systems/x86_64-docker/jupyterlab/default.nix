{ pkgs, inputs, lib, nixos-hardware, nixosModules, ... }:
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
  home-manager.users.nixos.snowfallorg.user.name = "nixos";
  # boot.loader.grub = enabled;

  excalibur = {
    # nix = enabled;
    # cli-apps = {
    #   flake = enabled;
    # };
    tools = {
      git = enabled;
      misc = enabled;
    };
    services = {
      # openssh = enabled;
      jupyter = enabled;
      entrypoint = {
        enable = false;
        # user = "nixos";
        # group = "wheel";
      };
    };
    # system = {
    #   fonts = enabled;
    #   locale = enabled;
    #   time = enabled;
    #   xkb = enabled;
    # };
    user = {
      name = "nixos";
      fullName = "Juca";
      email = "reinaldo800@gmail.com";
      extraGroups = [ "wheel" ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
