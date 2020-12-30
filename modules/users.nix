{ config, pkgs, ... }:

{
  users.users = {
    berberman = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
      shell = pkgs.zsh;
    };
  };
}
