{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    berberman = {
      url = "github:berberman/flakes";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };
    emacs = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ircbot = {
      url = "github:unsafeIO/ircbot";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = inputs@{ self, nixpkgs, berberman, home-manager, emacs, deploy-rs
    , flake-utils, agenix, ircbot }:
    let
      cachix = ./cachix;
      global = import ./global.nix;
      overlay = { nixpkgs.overlays = [ self.overlays.default ]; };
      desktop = rec {
        home = {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.berberman = import ./desktop/home;
        };
        shared = let dir = ./desktop/shared;
        in with builtins; map (x: dir + ("/" + x)) (attrNames (readDir dir));
        modules = [
          agenix.nixosModule
          home
          home-manager.nixosModules.home-manager
          cachix
          overlay
        ] ++ shared;
      };
      server = rec {
        shared = let dir = ./server/shared;
        in with builtins; map (x: dir + ("/" + x)) (attrNames (readDir dir));
        modules = [ agenix.nixosModule cachix overlay ] ++ shared;
      };
      mkDesktopSystem = { system, modules }:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit global inputs; };
          inherit system;
          modules = desktop.modules ++ modules;
        };
      mkServerSystem = { system, modules }:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit global inputs; };
          inherit system;
          modules = server.modules ++ modules;
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
            agenix.defaultPackage.${system}
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
          POTATO-NN = mkDesktopSystem {
            system = "x86_64-linux";
            modules = [ ./desktop/machines/nn/configuration.nix ];
          };
          POTATO-NR = mkDesktopSystem {
            system = "x86_64-linux";
            modules = [ ./desktop/machines/nr/configuration.nix ];
          };
          POTATO-O0 = mkServerSystem {
            system = "x86_64-linux";
            modules = [ ./server/machines/o0/configuration.nix ];
          };
          POTATO-HZ4 = mkServerSystem {
            system = "x86_64-linux";
            modules = [ ./server/machines/hz4/configuration.nix ];
          };
        };

        deploy.nodes = {
          POTATO-O0 = {
            sshUser = "root";
            profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos
              self.nixosConfigurations.POTATO-O0;
            hostname = "o0.typed.icu";
          };
          POTATO-HZ4 = {
            sshUser = "root";
            profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos
              self.nixosConfigurations.POTATO-HZ4;
            hostname = "hz4.typed.icu";
          };

        };
      };
}
