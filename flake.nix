{

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    berberman.url = "github:berberman/flakes";
    poscat.url = "github:poscat0x04/nix-repo";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, nixpkgs, berberman, poscat, home-manager, ... }: {

    overlays = [
      (final: prev: import ./overlays.nix final prev)
      berberman.overlay
      (final: prev: {
        inherit (poscat.overlay final prev) fcitx5-material-color;
      })
    ];

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
