{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.ethereum.consensus.prysm;
in {
  imports = [
    ./beacon.nix
    ./validator.nix
  ];

  config = mkIf (cfg.beacon-chain.enable || cfg.validator.enable || cfg.client-stats.enable) {
    # TODO: Create a "prysm" user for each of the prysm services to run under?
  };
}
