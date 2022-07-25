{ config, pkgs, ... }:

{
  users.users = {
    berberman = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "adbusers" "docker" ];
      shell = pkgs.zsh;
    };
  };
}
