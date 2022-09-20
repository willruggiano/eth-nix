{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.prysm.beacon;
in {
  options.services.prysm.beacon = {
    enable = mkEnableOption "Prysm beacon node";
    package = mkOption {
      type = types.package;
      default = pkgs.prysm;
    };
    eth1-header-req-limit = mkOption {
      type = types.int;
      description = "Maximum number of headers that a deposit log query can fetch";
      default = 1000;
    };
    network = mkOption {
      type = with types; enum ["mainnet" "prater" "pyrmont"];
      description = "The network to run on";
      default = "prater";
    };
    p2p-max-peers = mkOption {
      type = types.int;
      description = "Maximum number of p2p peers to maintain";
      default = 45;
    };
    web3provider = mkOption {
      type = types.str;
      description = "The primary execution node";
    };
    web3providerFallbacks = mkOption {
      type = with types; listOf str;
      description = "Fallback execution node(s)";
      default = [];
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.beacon = {
      description = "Prysm beacon node";
      enable = true;
      wantedBy = ["default.target"];
      serviceConfig = {
        ExecStart = let
          fallback-web3providers = with strings; concatMapStrings (p: "--fallback-web3provider " + p) cfg.web3providerFallbacks;
        in ''
          ${cfg.package}/bin/beacon-chain \
            --rpc-host 0.0.0.0 --grpc-gateway-host 0.0.0.0 --monitoring-host 0.0.0.0 \
            --http-web3provider ${cfg.web3provider} ${fallback-web3providers} \
            --eth1-header-req-limit ${toString cfg.eth1-header-req-limit} \
            --p2p-max-peers ${toString cfg.p2p-max-peers} \
            --${cfg.network} \
            --accept-terms-of-use
        '';
        Restart = "always";
        RestartSec = 30;
      };
    };
  };
}
