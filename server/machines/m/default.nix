{ config, pkgs, global, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./secrets.nix
    ./transmission.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  services.openssh.listenAddresses = [{
    addr = "0.0.0.0";
    port = 20998;
  }];

  networking = {
    hostName = "POTATO-M";
    interfaces.ens18 = {
      ipv4.addresses = [{
        address = "10.0.1.109";
        prefixLength = 24;
      }];
      ipv6.addresses = [{
        address = "2a01:4f9:4a:286f:1:109::";
        prefixLength = 96;
      }];
    };
    # interfaces.ens19 = {
    #   ipv4.addresses = [{
    #     address = "10.0.2.109";
    #     prefixLength = 24;
    #   }];
    #   ipv6.addresses = [{
    #     address = "2605:6400:c6ec:109::";
    #     prefixLength = 64;
    #   }];
    # };
    defaultGateway = {
      address = "10.0.1.1";
      interface = "ens18";
    };
    defaultGateway6 = {
      address = "2a01:4f9:4a:286f:1::1";
      interface = "ens18";
    };
    nameservers =
      [ "8.8.8.8" "8.8.4.4" "2001:4860:4860::8888" "2001:4860:4860::8844" ];
  };

  networking.firewall.enable = false;

  networking.wireguard.interfaces = {
    wg0 = {
      inherit (global.wg.m) ips listenPort peers;
      privateKeyFile = global.wg.m.privateKeyFile config;
    };
  };

  systemd.services.netns-lu = let
    startScript = pkgs.writeShellScript "start-netns-lu" ''
      ${pkgs.iproute2}/bin/ip netns add lu
      ${pkgs.iproute2}/bin/ip link set ens19 netns lu
      ${pkgs.iproute2}/bin/ip netns exec lu ${pkgs.iproute2}/bin/ip link set ens19 up
      ${pkgs.iproute2}/bin/ip netns exec lu ${pkgs.iproute2}/bin/ip addr add 10.0.2.109/24 dev ens19
      ${pkgs.iproute2}/bin/ip netns exec lu ${pkgs.iproute2}/bin/ip route add default via 10.0.2.1

      ${pkgs.iproute2}/bin/ip link add type veth
      ${pkgs.iproute2}/bin/ip link set veth0 netns lu
      ${pkgs.iproute2}/bin/ip netns exec lu ${pkgs.iproute2}/bin/ip link set veth0 up
      ${pkgs.iproute2}/bin/ip netns exec lu ${pkgs.iproute2}/bin/ip addr add 10.0.9.1/24 dev veth0
      ${pkgs.iproute2}/bin/ip link set veth1 up
      ${pkgs.iproute2}/bin/ip addr add 10.0.9.2/24 dev veth1
    '';
    stopScript = pkgs.writeShellScript "stop-netns-lu" ''
      ${pkgs.iproute2}/bin/ip netns exec lu ${pkgs.iproute2}/bin/ip link set ens19 down
      ${pkgs.iproute2}/bin/ip netns exec lu ${pkgs.iproute2}/bin/ip link set ens19 netns 1

      ${pkgs.iproute2}/bin/ip netns exec lu ${pkgs.iproute2}/bin/ip link set veth0 down
      ${pkgs.iproute2}/bin/ip netns exec lu ${pkgs.iproute2}/bin/ip link delete veth0

      ${pkgs.iproute2}/bin/ip netns delete lu
    '';
  in {
    enable = true;
    after = [ "network-pre.target" ];
    before = [ "network.target" "network-online.target" ];
    wantedBy = [ "multi-user.target" "network-online.target" ];
    serviceConfig = {
      RemainAfterExit = true;
      Type = "oneshot";
      ExecStop = stopScript;
      ExecStart = startScript;
    };
  };
  system.stateVersion = "22.05";
}
