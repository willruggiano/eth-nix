{
  stdenv,
  fetchgit,
  cmake,
  gmp,
}:
stdenv.mkDerivation rec {
  pname = "bls";
  version = "1.29";

  src = fetchgit {
    url = "https://github.com/herumi/bls";
    rev = "v${version}";
    hash = "sha256-fK6uC9DUKX+UezntM6aqXH3VlJ7+YrKIXfd8VrMeN9o=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [cmake];
  buildInputs = [gmp];
}
