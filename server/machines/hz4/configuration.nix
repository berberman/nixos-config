{ ... }: {
  imports = [ ./hardware-configuration.nix ./matrix.nix ];
  networking.hostName = "POTATO-HZ4";
}
