{
  description = "A Shell that is alos a Container";

  # Specifies the inputs for this flake, such as nixpkgs
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-julia.url = "github:NixOS/nixpkgs/?ref=refs/pull/225513/head";
    poetry2nix.url = "github:nix-community/poetry2nix";
  };

  # Use flake-utils to simplify flake outputs for multiple systems
  outputs =
    { self
    , pre-commit-hooks
    , poetry2nix
    , nixpkgs
    , flake-utils
    , ...
    }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ poetry2nix.overlays.default ];
        config = { allowUnfree = true; };
      };
      julia-env =
        pkgs.julia.withPackages [ "Pluto" "FileIO" "JLD2" "PythonCall" ];
      shell-env = pkgs.buildEnv rec {
        name = "shell-env";
        paths = [ julia-env pluto ];
      };
      pluto = pkgs.writeShellScriptBin "pluto" ''
        #!/usr/bin/env bash
        HOST="0.0.0.0" # Default host
        PORT=1234      # Default port

        # Parse command-line arguments for --host and --port
        while [[ "$#" -gt 0 ]]; do
            case $1 in
                --host) HOST="$2"; shift ;;
                --port) PORT="$2"; shift ;;
                *) echo "Unknown parameter passed: $1"; exit 1 ;;
            esac
            shift
        done

        ${julia-env}/bin/julia -e "using Pluto; Pluto.run(host=\"$HOST\", port=$PORT)"
      '';
      shell-img = pkgs.dockerTools.buildNixShellImage {
        name = "shell-container";
        tag = "latest";
        drv = shell;
        command = "${pluto}/bin/pluto --port ${"PORT:-1234"}";
      };
      shell = pkgs.mkShell {
        buildInputs = [ shell-env ];
        shellHook = ''
          echo "Example Shell Container with Pluto.jl" | ${pkgs.figlet}/bin/figlet
        '';
      };
      # adds shell hooks to the nix dev shell but not the container this creates
      devShell = pkgs.mkShell {
        buildInputs = shell.buildInputs ++ self.checks.${system}.pre-commit-check.enabledPackages;
        shellHook = shell.shellHook + "\n" + (self.checks.${system}.pre-commit-check.shellHook or "");
      };
    in
    {
      packages = {
        container = shell-img;
        pluto = pluto;
      };
      checks = {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixpkgs-fmt.enable = true;
          };
        };
      };
      devShells.default = devShell;
    });
}
