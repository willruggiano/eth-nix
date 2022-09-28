{
  system,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  autoPatchelfHook,
}: let
  version = "3.1.1";
  processor =
    if system == "x86_64-linux"
    then "amd64"
    else "arm64";
  beacon-chain = fetchurl {
    url = "https://github.com/prysmaticlabs/prysm/releases/download/v${version}/beacon-chain-v${version}-linux-${processor}";
    hash =
      if system == "x86_64-linux"
      then "sha256-kXw39BUGGC2nBhqi6aFb3sxdMOqv3CaIybD7pwc6fQU="
      else "sha256-l2ZawP9Uyfj5fJmUlRnRPuqWSgnezBfigwsUydbcGyQ=";
  };
  client-stats = fetchurl {
    url = "https://github.com/prysmaticlabs/prysm/releases/download/v${version}/client-stats-v${version}-linux-${processor}";
    hash =
      if system == "x86_64-linux"
      then "sha256-RK3LwdXL9vwv+YCmiHbgmJZ8pONxgTmU2y47elBBaMk="
      else "sha256-qo5uc/fJAUgw52xw9imLIzGvhfd0ZTXhLd+aofBXEK0=";
  };
  prysmctl = fetchurl {
    url = "https://github.com/prysmaticlabs/prysm/releases/download/v${version}/prysmctl-v${version}-linux-${processor}";
    hash =
      if system == "x86_64-linux"
      then "sha256-/FNx5wKJzM4p0KiwvIWFyY3tSjbBfZyeWKBXCgrmBK8="
      else "sha256-Qq5SRj8geNTJUPnAQUvyJ8pwvcTqyP4vur02U3TGijg=";
  };
  validator = fetchurl {
    url = "https://github.com/prysmaticlabs/prysm/releases/download/v${version}/validator-v${version}-linux-${processor}";
    hash =
      if system == "x86_64-linux"
      then "sha256-tspT7WvX/x+WavF5cwzpqocfBFYw3D0iTffJP94ndGw="
      else "sha256-8f8vdlmtMZ3spCF/7pNDR8TronH+oq6JxLZR/FZ+EJE=";
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
