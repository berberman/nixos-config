{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    berberman = {
      url = "github:berberman/flakes";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };
    emacs.url = "github:nix-community/emacs-overlay";
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self, nixpkgs, berberman, home-manager, emacs, deploy-rs, flake-utils }:
    let
      cachix = ./cachix;
      overlay = { nixpkgs.overlays = [ self.overlays.default ]; };
      desktop = rec {
        home = {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.berberman = import ./desktop/home;
        };
        shared = let dir = ./desktop/shared;
        in with builtins; map (x: dir + ("/" + x)) (attrNames (readDir dir));
        modules = [ home home-manager.nixosModules.home-manager cachix overlay ]
          ++ shared;
      };
      server = rec {
        shared = let dir = ./server/shared;
        in with builtins; map (x: dir + ("/" + x)) (attrNames (readDir dir));
        modules = [ cachix overlay ] ++ shared;
      };
    in flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
      in {
        legacyPackages = pkgs;
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.deploy-rs.deploy-rs
            (pkgs.haskellPackages.ghcWithPackages
              (p: with p; [ xmonad xmonad-contrib ]))
          ];
        };
      }) // {

        overlays.default = final: prev:
          (nixpkgs.lib.composeManyExtensions [
            (final: prev: import ./overlays.nix final prev)
            berberman.overlay
            emacs.overlay
            deploy-rs.overlay
          ]) final prev;

        nixosConfigurations = {
          POTATO-NN = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = desktop.modules
              ++ [ ./desktop/machines/nn/configuration.nix ];
          };
          POTATO-NR = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = desktop.modules
              ++ [ ./desktop/machines/nr/configuration.nix ];
          };
          POTATO-O0 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = server.modules
              ++ [ ./server/machines/o0/configuration.nix ];
          };
        };

        deploy.nodes = {
          POTATO-O0 = {
            sshUser = "root";
            profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos
              self.nixosConfigurations.POTATO-O0;
            hostname = "o0.typed.icu";
          };
        };
      };
}
