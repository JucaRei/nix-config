{ lib
, host ? null
, ...
}:
let
  inherit (lib) types;
  inherit (lib.excalibur) mkOpt;
in
{
  options.excalibur.host = {
    name = mkOpt (types.nullOr types.str) host "The host name.";
  };
}
