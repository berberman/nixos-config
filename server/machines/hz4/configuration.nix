{ ... }: {
  imports = [ ./hardware-configuration.nix ./matrix.nix ];
  networking.hostName = "POTATO-HZ4";
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "acme@typed.icu";
}
