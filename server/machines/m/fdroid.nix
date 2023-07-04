{ pkgs, lib, config, ... }:

let fdroidDir = "/var/lib/fdroid";
in {
  users.users.fdroid = {
    description = "Fdroid repo";
    isSystemUser = true;
    createHome = true;
    home = fdroidDir;
    group = "fdroid";
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [''
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ8B/MfMbtFfwF2YVlo5E4jFnJj0zcXgXQgCeBnAozS3 fdroid
    ''];
  };
  users.groups.fdroid = { };
  services.nginx.enable = true;
  services.nginx.virtualHosts."fdroid" = {
    listen = [{
      addr = "10.100.0.2";
      port = 8008;
    }];
    root = fdroidDir;
  };
}
