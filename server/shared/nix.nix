{ pkgs, ... }: {
  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
      dates = "weekly";
    };
    nixPath = [ "nixpkgs=${pkgs.path}" ];
  };
}
