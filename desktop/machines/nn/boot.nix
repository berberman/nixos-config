{ config, pkgs, ... }:

{
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/EFI";
    };
    grub = {
      devices = [ "nodev" ];
      efiSupport = true;
      enable = true;
      extraEntries = ''
        menuentry "Windows" {
          insmod part_gpt
          insmod fat
          insmod search_fs_uuid
          insmod chain
          set root=(hd2,gpt2)
          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }
      '';
    };
  };
}
