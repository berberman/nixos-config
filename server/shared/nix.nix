{ pkgs, inputs, ... }: {
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
      dates = "weekly";
    };
    nixPath = [ "nixpkgs=${pkgs.path}" ];
    registry.nixpkgs.flake = inputs.nixpkgs;
  };
  nixpkgs.config.allowUnfree = true;
}
