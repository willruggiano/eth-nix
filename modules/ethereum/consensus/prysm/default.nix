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

  options.services.ethereum.consensus.prysm = {
    package = mkOption {
      type = types.package;
      default = pkgs.prysm;
    };
  };

  config = mkIf (cfg.beacon-chain.enable || cfg.validator.enable || cfg.client-stats.enable) {
    environment.systemPackages = [cfg.package];
  };
}
