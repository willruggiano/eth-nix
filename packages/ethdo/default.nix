{ buildGoModule, fetchFromGitHub, ... }:

buildGoModule rec {
  pname = "ethdo";
  version = "1.15.1";

  src = fetchFromGitHub {
    owner = "wealdtech";
    repo = "ethdo";
    rev = "v${version}";
    hash = "sha256-kH6Y3/5jvkP0C7Ok2Ve+VEzAk3TMG6ji+XO7UzDBfIQ=";
  };

  runVend = true;
  vendorSha256 = "sha256-DWN2x3zDAliIo2nO1O2EoGyoBknXgL7NBXtuOZ9/vME=";

  doCheck = false;
}
