{ ... }: {
  imports = let dir = ./.;
  in with builtins;
  map (x: dir + ("/" + x))
  (filter (x: x != "default.nix") (attrNames (readDir dir)));
}
