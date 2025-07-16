rec {
  secretsDir = ./secrets;
  secretFile = name: secretsDir + ("/" + name + ".age");
  mkSecrets = names:
    with builtins;
    listToAttrs (map (n: {
      name = n;
      value = { file = secretFile n; };
    }) names);
  pubKeys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCzYkW1Zd2a4iwT+oG2zdLEWr3atozj8nRFAkoc93zWTAqN3XKppRWV6orpgqQfx4q/7oEYUhsN7zxh4ED/Xq1Eo0hMYRtT3nnSDadt++QLmbiUVaEl5QnrjNnfP2XDdzpuPWGpLAoBuettDJhr0jjJ7aYGD6cuS8YEXKZPbgKvF0NwduSln42vwqIR38rk/Rp77CNbGDuayGmPdk3OoJVgO7gos6dEKhzzXI54EnfydfDnExi1PxV+wdWnYSWn+bNctgQb5AkoiSUjOaTZp530mMP/ItY5IzUM+CST7CQxbhKUtyiyVD6aREA/USikIRvryRw3x4ZazUBPCxBiUQqNP+Psn4N14m57nneLuLfttgRuHkHbvPXYKc5p0965f4brfhfIAa5/Owoh0RRbFRnK3Dr7CBAX2N0CW515QIYMgtpOVqtKGy9uQbPmwS5jxGlQRcFeGbMR/JG+vOllb1AA1VQVEn0CbyLRsb3GU7jtjJV9/um8H/NSSiFC94PP6qpM0BB2M9NgPXtMaqtYWLaxIW67UY8pLM7zPoGQFEPgb79BmuXodh3C8deG3lWzAa5NBbOESSBfjyYsLiKi6dyoOjbmaAobfscVt2l9efRQgNvXgCNCb7GerViYFxB5SxCvU9EIXZn/9YsX3aIjA6HpQgK/zwaqr9TsT83KwErYrw=="
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyLGJ/xo8nFeWgSa1I9wSU/yKuyOS2wk8Rpx9Ahhidq"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJtNHlueefCXzAPweadIfLeDSGCnFxAxzjXLak5JdFc5 POTATO-O0"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOc0Ip5yHiuKkeeVeOC03w8ZSGrqRf73qVIaq1vaToXd POTATO-NR"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMCGWBq8CwZJa/TcI63gZQM61exLYaHBxPeX8/hU9W/9 POTATO-O1"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMKIkqj9mfV/UHSLq07xxFdMmi3kOKlyWi7qQcjUvkIr POTATO-M"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILVnYqmTUjCR+RJxXwHJyJrX0u3qjXrnPFwPIBOCfXHu POTATO-OA"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA7tqOZvLlTcmx1j1LZUjIVqy+GnIfxTj5XOvWR6Ddcq POTATO-NN"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJjKibWubbMbpIqwhpLZ76obXatOxmSY//1Ln3PcDwct POTATO-RM"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOnREg/xEmAlq2ZRlLDplh6X7ZTMUVGlvtWtLDWTUp7Q POTATO-T"
  ];
  netdataApiKey = "b9a20226-d54a-49e0-b63b-8eed5234ac18";
  wg = let
    listenPort = 20988;
    mkPeer = { public, private, ip, endpoint ? null, nat ? false }: {
      inherit public endpoint listenPort ip;
      ips = [ (ip + "/24") ];
      privateKeyFile = config: config.age.secrets.${private}.path;
      dynamicEndpointRefreshSeconds = 5;
      peers = with builtins;
        map (x:
          {
            publicKey = x.public;
            allowedIPs = [ (x.ip + "/32") ];
          } // (if nat then { persistentKeepalive = 25; } else { })
          // (if x.endpoint != null then { inherit (x) endpoint; } else { }))
        (filter (x: x.ip != ip) (attrValues wg));
    };
  in {
    o1 = mkPeer {
      ip = "10.100.0.1";
      public = "0tlbloisrfwumvqhZGirdyDg05S9Ex9LEGGG+8vsNFg=";
      private = "wg-o1-private";
      endpoint = "o1.torus.icu:${toString listenPort}";
    };
    m = mkPeer {
      ip = "10.100.0.2";
      public = "fxv+DpMAXw71JuiO/kNMUwhOzFVPOcVVpm1zLBaJKH8=";
      private = "wg-m-private";
      endpoint = "m.torus.icu:${toString listenPort}";
    };
    o0 = mkPeer {
      ip = "10.100.0.3";
      public = "+jnxWjZFK9h4OlwuwcoNOM4wQmQvuzOXudRthTa9PSQ=";
      private = "wg-o0-private";
      endpoint = "o0.torus.icu:${toString listenPort}";
    };
    oa = mkPeer {
      ip = "10.100.0.4";
      public = "Hq/HLG2S59Ter05v7WN+QfJRhO1l249V5qYsHtKY0V8=";
      private = "wg-oa-private";
      endpoint = "oa.torus.icu:${toString listenPort}";
    };
    nr = mkPeer {
      ip = "10.100.0.5";
      public = "JlYqeP3QvfY+YTHg1374+D/mz7QIqkIpXHayIqgnlWo=";
      private = "wg-nr-private";
      nat = true;
    };
    t = mkPeer {
      ip = "10.100.0.6";
      public = "uHbuzDivJCU+uR4UZnhg1uynTQMYXyfVe0xPJpAgkzo=";
      private = "wg-t-private";
      endpoint = "t.torus.icu:${toString listenPort}";
    };
  };
}
