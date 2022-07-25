{
  nix.settings = {
    substituters = [
      "https://ghc-nix.cachix.org"
    ];
    trusted-public-keys = [
      "ghc-nix.cachix.org-1:wI8l3tirheIpjRnr2OZh6YXXNdK2fVQeOI4SVz/X8nA="
    ];
  };
}
