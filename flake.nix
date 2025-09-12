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
    emacs = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    ircbot = {
      url = "github:unsafeIO/ircbot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yandere-pic-bot = {
      url = "github:unsafeIO/yandere-pic-bot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-matrix-appservices = {
      url = "gitlab:coffeetables/nix-matrix-appservices";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      flake = false;
      url = "github:nix-community/nixos-vscode-server";
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; }
    ({ self, withSystem, flake-parts-lib, ... }:
      let flakeModules.default = ./flake-modules/default.nix;
      in {
        imports =
          [ flakeModules.default flake-parts.flakeModules.flakeModules ];

        hosts = {
          POTATO-NN = {
            isDesktop = true;
            modules = [ ./desktop/machines/nn ];
          };
          POTATO-NR = {
            isDesktop = true;
            modules = [ ./desktop/machines/nr ];
          };
          POTATO-RM = {
            isDesktop = true;
            modules = [ ./desktop/machines/rm ];
          };
          POTATO-O0 = {
            isDesktop = false;
            modules = [ ./server/machines/o0 ];
            deploy = {
              enabled = true;
              hostname = "o0.torus.icu";
            };
          };
          POTATO-O1 = {
            isDesktop = false;
            modules = [ ./server/machines/o1 ];
            deploy = {
              enabled = true;
              hostname = "o1.torus.icu";
            };
          };
          POTATO-OA = {
            isDesktop = false;
            system = "aarch64-linux";
            modules = [ ./server/machines/oa ];
            deploy = {
              enabled = true;
              hostname = "oa.torus.icu";
              remoteBuild = true;
            };
          };
          POTATO-T = {
            isDesktop = false;
            modules = [ ./server/machines/t ];
            deploy = {
              enabled = true;
              hostname = "t.torus.icu";
              remoteBuild = true;
            };
          };
        };
        flake = let
        in {
          inherit flakeModules;
          nixosModules.default = import ./modules;
          overlays.default = final: prev:
            (inputs.nixpkgs.lib.composeManyExtensions [
              (final: prev: import ./overlays.nix final prev)
              inputs.berberman.overlays.default
              inputs.emacs.overlay
              inputs.deploy-rs.overlays.default
            ]) final prev;
        };

        systems = [ "x86_64-linux" "aarch64-linux" ];
        perSystem = { system, pkgs, ... }: {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };
          devShells.default = pkgs.mkShell {
            buildInputs = [
              inputs.agenix.packages.${system}.default
              pkgs.deploy-rs.deploy-rs
              pkgs.wireguard-tools
              # (pkgs.haskellPackages.ghcWithPackages
              #   (p: with p; [ xmonad xmonad-contrib ]))
            ];
          };
        };
      });
}

