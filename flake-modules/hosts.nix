{ lib, config, self, inputs, ... }:
let cfg = config.hosts;
in {
  options = {
    hosts = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({ ... }: {
        options = {
          system = lib.mkOption {
            type = lib.types.str;
            default = "x86_64-linux";
          };
          modules = lib.mkOption {
            type = lib.types.listOf lib.types.path;
            default = [ ];
          };
          isDesktop = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
          deploy = {
            enabled = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
            sshUser = lib.mkOption {
              type = lib.types.str;
              default = "root";
            };
            hostname = lib.mkOption {
              type = lib.types.str;
              default = "";
            };
            remoteBuild = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
          };
        };
      }));
    };
  };
  config.flake.nixosConfigurations = let
    cachix = ../cachix;
    global = import ../global.nix;
    overlayModule = { nixpkgs.overlays = [ self.overlays.default ]; };
    desktop = rec {
      home = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.berberman = import ../desktop/home;
      };
      shared = let dir = ../desktop/shared;
      in with builtins; map (x: dir + ("/" + x)) (attrNames (readDir dir));
      modules = [
        self.nixosModules.default
        inputs.agenix.nixosModules.default
        home
        inputs.home-manager.nixosModules.home-manager
        cachix
        overlayModule
      ] ++ shared;
    };
    server = rec {
      shared = let dir = ../server/shared;
      in with builtins; map (x: dir + ("/" + x)) (attrNames (readDir dir));
      modules = [
        self.nixosModules.default
        inputs.agenix.nixosModules.default
        cachix
        overlayModule
        inputs.nix-matrix-appservices.nixosModule
      ] ++ shared;
    };
    mkDesktopSystem = { system, modules }:
      inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit global inputs; };
        inherit system;
        modules = desktop.modules ++ modules;
      };
    mkServerSystem = { system, modules }:
      inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit global inputs; };
        inherit system;
        modules = server.modules ++ modules;
      };
  in lib.concatMapAttrs (hostName: hostConfig:
    let
      mkSystem =
        if hostConfig.isDesktop then mkDesktopSystem else mkServerSystem;
    in { ${hostName} = mkSystem { inherit (hostConfig) system modules; }; })
  cfg;
  config.flake.deploy.nodes = lib.concatMapAttrs (hostName: hostConfig:
    let
      mkNode = {
        inherit (hostConfig.deploy) sshUser hostname remoteBuild;
        profiles.system.path =
          inputs.deploy-rs.lib.${hostConfig.system}.activate.nixos
          self.nixosConfigurations.${hostName};
      };
    in { ${hostName} = mkNode; })
    (lib.filterAttrs (_: hostConfig: hostConfig.deploy.enabled or false) cfg);
}
