{ config, pkgs, modulesPath, global, ... }: {

  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" ];

  boot.cleanTmpDir = true;

  zramSwap.enable = true;

  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys = global.pubKeys;

  system.stateVersion = "22.05";

  documentation.nixos.enable = false;

  environment.systemPackages = with pkgs; [
    vim
    neofetch
    htop
    git
    rsync
    ripgrep
    wget
    bat
  ];
}
