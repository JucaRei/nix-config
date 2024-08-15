{ lib
, writeText
, writeShellApplication
, substituteAll
, gum
, inputs
, pkgs
, hosts ? { }
, ...
}:
with lib;
with lib.excalibur;
let
  inherit (lib) mapAttrsToList concatStringsSep;
  inherit (lib.excalibur) override-meta;
  julia-env = pkgs.julia.withPackages.override
    {
      extraLibs =
        [ pkgs.libxcrypt pkgs.libxcrypt-legacy pkgs.openssl pkgs.cyrus_sasl ];
    } [
    "FileIO"
    "JLD2"
    "DataFrames"
    "MLJ"
    "PyCall"
    "IJulia"
    "CSV"
    "LanguageServer"
  ];

  startJupyterWithJulia = createJuliaConsole "julia-console"
    "${pkgs.jupyter-all}/bin/jupyter console"
    {
      pkgs = pkgs;
      juliaEnv = julia-env;
      kernelName = "excalibur";
    };
  startQtJupyterWithJulia = createJuliaConsole "julia-qtconsole"
    "${pkgs.jupyter-all}/bin/jupyter qtconsole"
    {
      pkgs = pkgs;
      juliaEnv = julia-env;
      kernelName = "excalibur";
    };
in
pkgs.stdenv.mkDerivation rec {
  pname = "julia";
  version = pkgs.julia.version;
  src = ./.;

  buildInputs = [ pkgs.jupyter-all julia-env pkgs.openssl ];

  installPhase = ''
    mkdir -p $out/bin
    cp -r ${julia-env}/bin/julia $out/bin/julia
    cp -r ${startJupyterWithJulia}/bin/* $out/bin/
    cp -r ${startQtJupyterWithJulia}/bin/* $out/bin/
  '';
  mainProgram = "julia";

  passthru = {
    jupyter-qtconsole = startQtJupyterWithJulia;
    jupyter-console = startJupyterWithJulia;
  };
}
