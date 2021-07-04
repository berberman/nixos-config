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
  
#   vscode = super.vscode.overrideAttrs (old: rec{
#     version = "1.55.2";
#     
#     src = super.fetchurl {
#     name = "VSCode_${version}_linux-x64.tar.gz";
#     url = "https://update.code.visualstudio.com/${version}/linux-x64/stable";
#     sha256 = "08151qdhf4chg9gfbs0dl0v0k5vla2gz5dfy439jzdg1d022d5rw";
#     };
#   });

#   vscode-extensions.WakaTime.vscode-wakatime = super.vscode-extensions.WakaTime.vscode-wakatime.overrideAttrs (old: {
#     postPatch = ''
#       mkdir wakatime-cli
#       ln -s ${self.wakatime}/bin/wakatime ./wakatime-cli/wakatime-cli 
#     '';
#   });

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
