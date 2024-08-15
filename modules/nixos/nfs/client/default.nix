{ options, config, lib, ... }:
with lib;
with lib.excalibur;
let cfg = config.excalibur.nfs.client;
in {
  options.excalibur.nfs.client = with types; {
    enable = mkBoolOpt false "NFS";
    webb = mkBoolOpt false "Whether or not to Webb mount.";
    campfs = mkBoolOpt false "Whether or not to campfs mount.";
    chestyfs = mkBoolOpt false "Whether or not to chestyfs mount.";
    k8s = mkBoolOpt false "Whether or not to k8s mount.";
    media = mkBoolOpt false "Whether or not to media mount.";
  };

  config = mkIf cfg.enable {
    services.rpcbind.enable = true; # needed for NFS
    systemd.mounts = let
      commonMountOptions = {
        type = "nfs";
        mountConfig = { Options = "noatime"; };
      };
    in [
      (commonMountOptions // {
        what = "reckless:/export/media";
        where = "/mnt/media";
      })

      (commonMountOptions // {
        what = "webb:/export/webb";
        where = "/mnt/webb";
      })

      (commonMountOptions // {
        what = "reckless:/export/nextcloud";
        where = "/mnt/nextcloud";
      })
    ];

    systemd.automounts = let
      commonAutoMountOptions = {
        wantedBy = [ "multi-user.target" ];
        automountConfig = { TimeoutIdleSec = "600"; };
      };
    in [
      (commonAutoMountOptions // { where = "/mnt/media"; })
      (commonAutoMountOptions // { where = "/mnt/webb"; })
      (commonAutoMountOptions // { where = "/mnt/nextcloud"; })
    ];
    #   fileSystems."/mnt/webb" = {
    #     device = "webb:/webb";
    #     fsType = "nfs";
    #     options = [ "rw" "soft" "x-systemd.automount" "noauto" ];
    #   };
    # } // mkIf cfg.campfs {
    #   fileSystems."/mnt/campfs" = {
    #     device = "campfs:/campfs";
    #     fsType = "nfs";
    #     options = [ "rw" "soft" "x-systemd.automount" "noauto" ];
    #   };
    # } // mkIf cfg.chestyfs {
    #   fileSystems."/mnt/chestyfs" = {
    #     device = "chesty:/mnt/chestyfs";
    #     fsType = "nfs";
    #     options = [ "rw" "soft" "x-systemd.automount" "noauto" ];
    #   };
    # } // mkIf cfg.media {
    #   fileSystems."/mnt/media" = {
    #     device = "webb:/export/media";
    #     fsType = "nfs";
    #     options = [ "rw" "soft" "x-systemd.automount" "noauto" ];
    #   };
    # } // mkIf cfg.k8s {
    #   fileSystems."/mnt/k8s" = {
    #     device = "k8s:/k8s";
    #     fsType = "nfs";
    #     options = [ "rw" "soft" "x-systemd.automount" "noauto" ];
    #   };
  };
}
