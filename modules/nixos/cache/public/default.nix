{
  config,
  lib,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.cache.public;
in {
  options.excalibur.cache.public = {
    enable = mkEnableOption "NixOS public cache";
  };
  config = mkIf cfg.enable {
    excalibur.nix.extra-substituters = {
      "https://cache.nixos.org/".key = "public:QUkZTErD8fx9HQ64kuuEUZHO9tXNzws7chV8qy/KLUk=";
    };
  };
}
