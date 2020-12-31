{

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, nixpkgs, home-manager, ... }: {

    overlays = [ (final: prev: import ./overlays.nix final prev) ];

    nixosConfigurations.POTATO-NN = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.berberman = import ./home;
        }
        { nixpkgs.overlays = self.overlays; }
      ];
    };

  };
}
