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

  mathematica = super.mathematica.overrideAttrs (old: rec {
    version = "12.3.0";
    name = "mathematica-${version}";
    src = super.requireFile rec {
      name = "Mathematica_${version}_LINUX.sh";
      message = "${name} is required!";
      sha256 =
        "045df045f6e796ded59f64eb2e0f1949ac88dcba1d5b6e05fb53ea0a4aed7215";
    };
  });

  netbeans = super.netbeans.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs ++ [ self.makeWrapper ];
    buildCommand = old.buildCommand + ''
      wrapProgram $out/bin/netbeans \
        --set _JAVA_AWT_WM_NONREPARENTING 1 
    '';
  });
}
