{ inputs
, lib
, config
, pkgs
, ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.services.nix-snapshotter;

  # preloadContainerdImages = [pkgs.excalibur.containers];
in
{
  imports = [ inputs.nix-snapshotter.nixosModules.default ];

  options.excalibur.services.nix-snapshotter = with types; {
    enable = mkBoolOpt false "Enable Nix Snapshotter;";
  };

  config = mkIf cfg.enable {
    virtualisation.containerd = {
      enable = true;
      nixSnapshotterIntegration = true;
    };
    services.nix-snapshotter = { enable = true; };

    environment.systemPackages = [ pkgs.nerdctl ];
  };
}
