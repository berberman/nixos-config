{ pkgs, config, global, inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./secrets.nix
    ./matrix.nix
    ./znc.nix
  ];
  # for trixnity
  nixpkgs.config.permittedInsecurePackages = [ "olm-3.2.16" ];
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.berberman = import ./home.nix;
  home-manager.extraSpecialArgs = { inherit inputs global; };
  users.users = {
    berberman = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = global.pubKeys;
    };
  };
  networking.hostName = "POTATO-OA";
  networking.firewall.enable = false;
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "acme@torus.icu";
  boot.zfs.devNodes = "/dev";
  networking.hostId = "c271c48d";
  networking.wireguard.interfaces = {
    wg0 = {
      inherit (global.wg.oa) ips listenPort peers;
      privateKeyFile = global.wg.oa.privateKeyFile config;
    };
  };
  networking.interfaces.enp0s3.ipv6.addresses = [{
    address = "2603:c024:c008:faff:12f3:41a2:58e8:8125";
    prefixLength = 128;
  }];
  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = "enp0s3";
  };

  services.ircbot = {
    enable = false;
    environmentFile = config.age.secrets.ircbot.path;
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    virtualHosts."oa.torus.icu" = {
      enableACME = true;
      forceSSL = true;
      default = true;
      locations."/".return = "302 https://torus.icu";
    };
  };
  system.stateVersion = "22.05";
}
