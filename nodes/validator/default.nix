{ config, pkgs, nodes, ... }:
let
  beacon-rpc-provider = "${nodes.beacon.config.deployment.targetHost}:4000";
in
{
  services.prysm.validator = {
    enable = true;
    inherit (nodes.beacon.config.services.prysm.beacon) network;
    inherit beacon-rpc-provider;
  };
}
