{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.tools.dvc;
in {
  options.excalibur.tools.dvc = with types; {
    enable = mkBoolOpt false "Whether or not to enable common DVC.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [dvc];

    # home.sessionVariables = {
    #   PYTHON_KEYRING_BACKEND="keyring.backends.null.Keyring";
    #   LD_LIBRARY_PATH = "${pkgs.gcc.cc.lib}/lib:${pkgs.zlib}/lib";
    # };
  };
}
