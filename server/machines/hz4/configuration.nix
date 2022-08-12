{ ... }: {
  imports = [ ./hardware-configuration.nix ./matrix.nix ];
  networking.hostName = "POTATO-HZ4";
  networking.interfaces.ens3.ipv6.addresses = [{
    address = "2a01:4f8:c012:8f4e::";
    prefixLength = 64;
  }];
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "acme@typed.icu";
}
