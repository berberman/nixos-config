{ pkgs, lib, config, ... }:

let fdroidDir = "/var/lib/fdroid";
in {
  users.users.fdroid = {
    description = "Fdroid repo";
    isSystemUser = true;
    createHome = true;
    home = fdroidDir;
    group = "fdroid";
    homeMode = "755";
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [''
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ8B/MfMbtFfwF2YVlo5E4jFnJj0zcXgXQgCeBnAozS3 fdroid
    ''];
    packages = with pkgs; [ fdroidserver openjdk11 ];
  };
  users.groups.fdroid = { };
  services.nginx.enable = true;
  services.nginx.virtualHosts."fdroid" = {
    listen = [{
      addr = "10.100.0.2";
      port = 8008;
    }];
    locations."/" = {
      root = "${fdroidDir}/web";
      extraConfig = ''
        sub_filter_once off;
        sub_filter '</body>' '<script src=../../fdroid-index.js></script></body>';
      '';
    };

  };
  nixpkgs = {
    overlays = [
      (final: prev:
        with prev; {
          androidComposition = androidenv.composeAndroidPackages {
            platformVersions = [ "34" ];
            buildToolsVersions = [ "34.0.0" ];
            platformToolsVersion = "34.0.5";
            includeNDK = false;
            includeEmulator = false;
            includeSources = false;
          };
          fdroidserver = writeScriptBin "fdroid" ''
            export ANDROID_HOME="${final.androidComposition.androidsdk}/libexec/android-sdk"
            exec -a "$0" ${fdroidserver}/bin/fdroid "$@"
          '';
        })
    ];
    config = {
      android_sdk.accept_license = true;
    };
  };
}
