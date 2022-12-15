{ modulesPath, ... }:

{
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };
  boot.initrd.availableKernelModules = [ "xhci_pci" "virtio_pci" "usbhid" ];
  fileSystems."/" = {
    device = "tank";
    fsType = "zfs";
  };

  fileSystems."/nix" = {
    device = "tank/nix";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/42DD-817B";
    fsType = "vfat";
  };

}
