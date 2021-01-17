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
