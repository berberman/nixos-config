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
    };
  };
  boot.kernelParams = [ "amdgpu.sg_display=0" ];
  # TODO: Linux 6.18.57/58 can bind this alongside button and signal PID 1 to power off.
  # https://discourse.nixos.org/t/tiny-power-button-kernel-module-causing-confusion/80683
  boot.blacklistedKernelModules = [ "tiny_power_button" ];
}
