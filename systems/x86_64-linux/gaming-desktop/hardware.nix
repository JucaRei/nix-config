# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }: {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/736342ee-c476-47d2-9a81-cb0f0ffeb852";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."luks-76c6fcfc-912c-4874-97d9-f97175ff34ac".device =
    "/dev/disk/by-uuid/76c6fcfc-912c-4874-97d9-f97175ff34ac";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/C18B-F62C";
    fsType = "vfat";
  };

  fileSystems."/home/mboterf/games" = {
    device = "/dev/disk/by-uuid/c53f29da-d5e5-4412-a49f-dd951ac1f664";
    fsType = "ext4";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/0adfdb68-e9a0-49bd-9561-c10bc0c72575"; }];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp7s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp6s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
