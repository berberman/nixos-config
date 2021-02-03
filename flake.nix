{

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    berberman.url = "github:berberman/flakes";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, nixpkgs, berberman, home-manager, ... }: {

    overlays =
      [ (final: prev: import ./overlays.nix final prev) berberman.overlay ];

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

    devShell.x86_64-linux = with (import nixpkgs { system = "x86_64-linux"; });
      mkShell {
        buildInputs = [
          haskell-language-server
          (haskellPackages.ghcWithPackages
            (p: with p; [ xmonad xmonad-contrib ]))
        ];
      };
  };
}
