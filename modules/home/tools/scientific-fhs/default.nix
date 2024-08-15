{ inputs, options, config, lib, ... }:
with lib;
with lib.excalibur;
let
  cfg = config.excalibur.tools.scientific-fhs;
  # inherit (inputs) scientific-fhs;
in {
  options.excalibur.tools.scientific-fhs = with types; {
    enable = mkBoolOpt false "Whether or not to enable common Scientific FHS.";
  };

  # imports = mkIf cfg.enable [ inputs.scientific-fhs.nixosModules.default ];

  config = mkIf cfg.enable {
    excalibur.tools.julia.enable = mkForce false;
    excalibur.tools.python.enable = mkForce false;

    # programs.scientific-fhs = {
    #   enable = true;
    #   # juliaVersions = [
    #   #   {
    #   #     version = "1.10.0";
    #   #     default = true;
    #   #   }
    #   # ];
    #   # enableNVIDIA = true;
    #   # enableGraphical = true;
    # };
  };
}
