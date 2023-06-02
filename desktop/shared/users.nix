{ config, pkgs, ... }:

{
  users.defaultUserShell = pkgs.zsh;
  users.users = {
    berberman = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "adbusers" "docker" ];
    };
  };
}
