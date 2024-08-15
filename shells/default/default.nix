{ mkShell, inputs, system, pkgs, lib, ... }:
with lib;
with lib.excalibur;
let
  # inherit (lib.excalibur) override-meta;
  inherit (inputs.self.hooks.${system}.pre-commit-check) shellHook;
in
mkShell {
  buildInputs = [
    pkgs.deadnix
    pkgs.hydra-check
    pkgs.nix-diff
    pkgs.nix-index
    pkgs.nix-prefetch-git
    pkgs.nixpkgs-fmt
    pkgs.nixpkgs-hammering
    pkgs.nixpkgs-lint
    pkgs.snowfallorg.flake
    pkgs.statix
    pkgs.excalibur.vault-scripts
    pkgs.vault
  ] ++ inputs.self.hooks.${system}.pre-commit-check.enabledPackages;

  shellHook = ''
    ${shellHook}
    echo 🏕️ Welcome to the excalibur
    # Additional setup can go here

  '';
}
