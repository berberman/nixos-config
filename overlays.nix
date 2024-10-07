self: super:

{
  # picom = super.picom.overrideAttrs (old: {
  #   version = "9.1-next";
  #   src = super.fetchFromGitHub {
  #     owner = "yshui";
  #     repo = "picom";
  #     rev = "7e56843ebfc0837d70deb9d73b36ae706462bd21";
  #     sha256 = "Fqk6bPAOg4muxmSP+ezpGUNw6xrMWchZACKemeA08mA=";
  #     fetchSubmodules = true;
  #   };
  # });

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

  # netbeans = super.netbeans.overrideAttrs (old: {
  #   nativeBuildInputs = old.nativeBuildInputs ++ [ self.makeWrapper ];
  #   buildCommand = old.buildCommand + ''
  #     wrapProgram $out/bin/netbeans \
  #       --set _JAVA_AWT_WM_NONREPARENTING 1 
  #   '';
  # });

}
