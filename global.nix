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
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHawvaRla83nkjdllxPFETN2vqbeMAnjzyeKfTVmom3l POTATO-HZ4"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMCGWBq8CwZJa/TcI63gZQM61exLYaHBxPeX8/hU9W/9 POTATO-O1"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMKIkqj9mfV/UHSLq07xxFdMmi3kOKlyWi7qQcjUvkIr POTATO-M"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILVnYqmTUjCR+RJxXwHJyJrX0u3qjXrnPFwPIBOCfXHu POTATO-OA"
  ];
  wg.public = {
    o1 = "0tlbloisrfwumvqhZGirdyDg05S9Ex9LEGGG+8vsNFg=";
    m = "fxv+DpMAXw71JuiO/kNMUwhOzFVPOcVVpm1zLBaJKH8=";
  };
}
