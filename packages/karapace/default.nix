{ lib
, writeText
, writeShellApplication
, substituteAll
, inputs
, pkgs
, hosts ? { }
, ...
}:
let
  inherit (lib) mapAttrsToList concatStringsSep;
  inherit (lib.excalibur) override-meta;

  new-meta = with lib; {
    description = "Karapace - a Kafka Schema Registry and REST Proxy";
    homepage = "https://github.com/Aiven-Open/karapace";
    license = licenses.mit; # Update the license if necessary
    maintainers = with maintainers; [ matt-camp ];
  };

  pname = "karapace";
  version = "3.12.0";

  accept-types = pkgs.nix-unstable.python311Packages.buildPythonPackage {
    pname = "accept-types";
    version = "0.4.1";

    src = pkgs.fetchPypi {
      pname = "accept-types";
      version = "0.4.1";
      sha256 = "sha256-+ycJlxbY8DYECMjKhtadv+1ERVg0tw0VBiUKvlIbU1o=";
    };
    doCheck = false;

    meta = {
      description = "accept-types";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ mattcamp ];
    };
  };

  karapace = pkgs.nix-unstable.python311Packages.buildPythonApplication {
    inherit pname;
    inherit version;

    src = pkgs.fetchFromGitHub {
      owner = "Aiven-Open";
      repo = "karapace";
      rev = version;
      sha256 =
        "sha256-Gw4R8QZOfP0cqxMPaes0MGOt0Qd4wJn9SWlcGq+D9b8="; # Placeholder hash
    };

    preBuild = ''
      export KARAPACE_VERSION="${version}"
    '';

    propagatedBuildInputs = with pkgs.nix-unstable.python311Packages;
      [
        zstandard
        python-snappy
        typing-extensions
        cachetools
        confluent-kafka
        aiohttp
        aiokafka
        avro
        aiohttp
        jsonschema
        networkx
        protobuf
        pyjwt
        ujson
        sentry-sdk
        python-dateutil
        kafka-python
        lz4
        watchfiles
      ] ++ [ accept-types ];
    doCheck = false;

    meta = with lib; {
      description = "Karapace - a Kafka Schema Registry and REST Proxy";
      homepage = "https://github.com/Aiven-Open/karapace";
      license = licenses.mit; # Update the license if necessary
      maintainers = with maintainers; [ ]; # Add maintainers here
    };
  };

  # python-env
in
override-meta new-meta karapace
