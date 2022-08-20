{ ... }: {
  imports = [ ./hardware-configuration.nix ./matrix.nix ./secrets.nix ];
  networking.hostName = "POTATO-HZ4";
  networking.useDHCP = false;
  networking.interfaces.ens3.useDHCP = true;
  networking.interfaces.ens3.ipv6.addresses = [{
    address = "2a01:4f8:c012:8f4e::";
    prefixLength = 64;
  }];
  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = "ens3";
  };
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "acme@typed.icu";
}
