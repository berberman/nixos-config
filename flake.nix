{

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    berberman = {
      url = "github:berberman/flakes";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs.url = "github:nix-community/emacs-overlay";
  };

  outputs = { self, nixpkgs, berberman, home-manager, emacs }: {

    overlays = [
      (final: prev: import ./overlays.nix final prev)
      berberman.overlay
      emacs.overlay
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

    devShell.x86_64-linux = with (import nixpkgs { system = "x86_64-linux"; });
      mkShell {
        buildInputs = [
          (haskellPackages.ghcWithPackages
            (p: with p; [ xmonad xmonad-contrib ]))
        ];
      };
  };
}
