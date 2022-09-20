{
  stdenv,
  fetchzip,
  autoPatchelfHook,
  gcc,
}:
stdenv.mkDerivation rec {
  pname = "ethdo";
  version = "1.25.3";

  src = fetchzip {
    url = "https://github.com/wealdtech/ethdo/releases/download/v${version}/ethdo-${version}-linux-amd64.tar.gz";
    hash = "sha256-n//ozqz+Orq38d5b1LkT54Hw22+Pdaisf98Au//Kv8o=";
  };

  nativeBuildInputs = [autoPatchelfHook stdenv.cc.cc.lib];

  dontConfigure = true;

  installPhase = ''
    install -m755 -D ethdo $out/bin/ethdo
  '';
}
