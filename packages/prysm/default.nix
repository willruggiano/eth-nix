{
  stdenv,
  fetchFromGitHub,
  fetchurl,
  autoPatchelfHook,
}: let
  version = "3.1.1";
  beacon-chain = fetchurl {
    url = "https://github.com/prysmaticlabs/prysm/releases/download/v${version}/beacon-chain-v${version}-linux-amd64";
    hash = "sha256-kXw39BUGGC2nBhqi6aFb3sxdMOqv3CaIybD7pwc6fQU=";
  };
  client-stats = fetchurl {
    url = "https://github.com/prysmaticlabs/prysm/releases/download/v${version}/client-stats-v${version}-linux-amd64";
    hash = "sha256-RK3LwdXL9vwv+YCmiHbgmJZ8pONxgTmU2y47elBBaMk=";
  };
  prysmctl = fetchurl {
    url = "https://github.com/prysmaticlabs/prysm/releases/download/v${version}/prysmctl-v${version}-linux-amd64";
    hash = "sha256-/FNx5wKJzM4p0KiwvIWFyY3tSjbBfZyeWKBXCgrmBK8=";
  };
  validator = fetchurl {
    url = "https://github.com/prysmaticlabs/prysm/releases/download/v${version}/validator-v${version}-linux-amd64";
    hash = "sha256-tspT7WvX/x+WavF5cwzpqocfBFYw3D0iTffJP94ndGw=";
  };
in
  stdenv.mkDerivation {
    pname = "prysm";
    inherit version;

    srcs = [
      beacon-chain
      client-stats
      prysmctl
      validator
    ];
    sourceRoot = ".";

    nativeBuildInputs = [autoPatchelfHook];

    dontUnpack = true;
    dontConfigure = true;

    installPhase = ''
      install -m755 -D ${beacon-chain} $out/bin/beacon-chain
      install -m755 -D ${client-stats} $out/bin/client-stats
      install -m755 -D ${prysmctl} $out/bin/prysmctl
      install -m755 -D ${validator} $out/bin/validator
    '';
  }
