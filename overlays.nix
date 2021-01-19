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

  # See https://github.com/NixOS/nixpkgs/pull/109649
  # fcitx5 still needs start from command line

  fcitx5-qt = super.libsForQt5.fcitx5-qt.overrideAttrs (old: {

    preConfigure = ''
      substituteInPlace qt5/platforminputcontext/CMakeLists.txt \
        --replace \$"{CMAKE_INSTALL_QT5PLUGINDIR}" $out/${super.qt5.qtbase.qtPluginPrefix}
    '';

  });

  fcitx5-chinese-addons =
    super.fcitx5-chinese-addons.override { fcitx5-qt = self.fcitx5-qt; };

  fcitx5-with-addons =
    super.fcitx5-with-addons.override { fcitx5-qt = self.fcitx5-qt; };

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
