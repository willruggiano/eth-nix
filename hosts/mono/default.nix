{inputs, ...}: let
  eth1network = "goerli";
  eth2network = "prater";
  beacon-rpc-provider = "127.0.0.1:4000";
  web3provider = "127.0.0.1:8545";
in {
  services.geth.execution = {
    enable = true;
    network = eth1network;
  };

  services.prysm = {
    beacon = {
      enable = true;
      network = eth2network;
      inherit web3provider;
    };
    validator = {
      enable = true;
      network = eth2network;
      inherit beacon-rpc-provider;
    };
    client-stats = {
      enable = true;
    };
  };

  services.openssh.enable = true;
}
