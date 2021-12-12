{ config, pkgs, ... }:

{
  users.users = {
    berberman = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "adbusers" ];
      shell = pkgs.zsh;
    };
  };
}
