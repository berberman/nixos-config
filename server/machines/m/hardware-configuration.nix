{ config, lib, ... }:

{

  boot.initrd.availableKernelModules =
    [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/f1e8e314-6dfa-4747-b8dd-eb5789cd2798";
    fsType = "ext4";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/9be8eafc-a6b7-46f7-a0fa-08576cf8ed5c"; }];

  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
