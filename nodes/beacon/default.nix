{
  config,
  pkgs,
  nodes,
  ...
}: let
  web3provider = "${nodes.execution.config.deployment.targetHost}:8545";
in {
  services.prysm.beacon = {
    enable = true;
    network = "prater";
    inherit web3provider;
  };
}
