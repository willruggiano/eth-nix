{
  buildGoModule,
  fetchFromGitHub,
  ...
}:
buildGoModule rec {
  pname = "prysm";
  version = "2.0.5";

  src = fetchFromGitHub {
    owner = "prysmaticlabs";
    repo = "prysm";
    rev = "v${version}";
    hash = "sha256-BahksjUBfNtZ1ImGj05kDpVlvC8G+cvcxNnNrTiYavY=";
  };

  runVend = true;
  vendorSha256 = "sha256-1EwG2bwMUt5c2tk1JtPCf95LMOEiKZU83ky1lv2xQGY=";

  doCheck = false;
}
