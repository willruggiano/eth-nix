{
  system,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:
stdenv.mkDerivation rec {
  pname = "mev-boost";
  version = "1.3.2";

  src = let
    arch =
      if system == "x86_64-linux"
      then "amd64"
      else "arm64";
    hash =
      if system == "x86_64-linux"
      then "sha256-WaOn5pXJRRjVwml2KdCL5HsWas46lFzGrdj4p5Caiec="
      else "";
  in
    fetchurl {
      url = "https://github.com/flashbots/mev-boost/releases/download/v${version}/mev-boost_${version}_linux_${arch}.tar.gz";
      inherit hash;
    };
  sourceRoot = ".";

  nativeBuildInputs = [autoPatchelfHook];

  dontConfigure = true;

  installPhase = ''
    install -m755 -D mev-boost $out/bin/mev-boost
  '';
}
