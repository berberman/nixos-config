self: super:

{
  picom = super.picom.overrideAttrs (old: {
    version = "8.3-next";
    src = super.fetchFromGitHub {
      owner = "yshui";
      repo = "picom";
      rev = "d974367a0446f4f1939daaada7cb6bca84c893ef";
      sha256 = "mx60aWR+4hlwMHwEhYSNXZfHfGog5c2aHolMtgkpVVY=";
      fetchSubmodules = true;
    };
  });

  # https://github.com/NixOS/nixpkgs/pull/108713
  enpass = super.enpass.overrideAttrs (old: {
    installPhase = (self.lib.removeSuffix "\n" old.installPhase) + " \\\n"
      + "  --unset QML2_IMPORT_PATH \\\n" + "  --unset QT_PLUGIN_PATH";
  });

  # qbittorrent = (super.qbittorrent.override {
  #      libtorrent-rasterbar = super.libtorrentRasterbar-1_2_x;
  #    }).overrideAttrs (old: rec {
  #      version = "4.3.2.10";
  #      src = super.fetchFromGitHub {
  #        owner = "c0re100";
  #        repo = "qBittorrent-Enhanced-Edition";
  #        rev = "release-${version}";
  #        sha256 = "l31sV97XoBsrecMV81CsbKtIQuAeLVMDmolmgIDIItY=";
  #      };
  #    });

}
