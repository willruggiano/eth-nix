{
  system,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  gcc,
}: let
  processor =
    if system == "x86_64-linux"
    then "amd64"
    else "arm64";
in
  stdenv.mkDerivation rec {
    pname = "ethdo";
    version = "1.25.3";

    src = fetchzip {
      url = "https://github.com/wealdtech/ethdo/releases/download/v${version}/ethdo-${version}-linux-${processor}.tar.gz";
      hash =
        if system == "x86_64-linux"
        then "sha256-n//ozqz+Orq38d5b1LkT54Hw22+Pdaisf98Au//Kv8o="
        else "sha256-9fpk325cvMOYEAbCjjMtzEoluHkDNxRmldDLXRRmiZY=";
    };

    nativeBuildInputs = [autoPatchelfHook stdenv.cc.cc.lib];

    dontConfigure = true;

    installPhase = ''
      install -m755 -D ethdo $out/bin/ethdo
    '';
  }
