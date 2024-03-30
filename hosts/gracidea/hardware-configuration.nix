{
  lib,
  modulesPath,
  system,
  ...
}: {
  imports = [(modulesPath + "/profiles/qemu-guest.nix")];

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "virtio_pci"
        "virtio_scsi"
        "usbhid"
      ];
      kernelModules = [];
    };

    loader.grub.device = "/dev/disk/by-id/scsi-3600926ab65fe44a8a4de80da89ca601b";

    kernelModules = [];
    extraModulePackages = [];
  };

  fileSystems = {
    "/" = {
      device = "rpool/local/root";
      fsType = "zfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/CA0D-E363";
      fsType = "vfat";
    };

    "/home" = {
      device = "rpool/safe/home";
      fsType = "zfs";
    };

    "/nix" = {
      device = "rpool/local/nix";
      fsType = "zfs";
    };

    "/persist" = {
      device = "rpool/safe/persist";
      fsType = "zfs";
    };
  };

  swapDevices = [{device = "/dev/disk/by-uuid/f2e46cff-3530-4a68-8a43-283eff1411a7";}];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = system;
}