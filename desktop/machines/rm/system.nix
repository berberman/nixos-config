{ config, pkgs, ... }:

{
  services.automatic-timezoned.enable = true;
  hardware.bluetooth.enable = true;
  environment.systemPackages = with pkgs; [ mathematica distrobox ];
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };
  system.replaceDependencies.replacements = [{
    oldDependency = pkgs.openconnect;
    newDependency = pkgs.openconnect.overrideAttrs (old: {
      src = pkgs.fetchFromGitLab {
        owner = "openconnect";
        repo = "openconnect";
        rev = "f17fe20d337b400b476a73326de642a9f63b59c8";
        hash = "sha256-OBEojqOf7cmGtDa9ToPaJUHrmBhq19/CyZ5agbP7WUw=";
      };
    });
  }];
  niri = {
    enable = true;
    ex = ''
      output "Thermotrex Corporation TL156MDMP31-0 Unknown" {
          scale 2
      }
    '';
  };
}
