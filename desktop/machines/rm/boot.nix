{ config, pkgs, ... }:

{
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      devices = [ "nodev" ];
      efiSupport = true;
      enable = true;
      useOSProber = true;
    };
  };
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/7c4d71a4-063d-4131-a862-42e41ccb11ed";
      preLVM = true;
    };
  };
  boot.kernelParams = [ "amdgpu.sg_display=0" ];
}
