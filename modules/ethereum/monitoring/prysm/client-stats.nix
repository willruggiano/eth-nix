{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.ethereum.monitoring.prysm.client-stats;
in {
  options.services.ethereum.monitoring.prysm.client-stats = {
    enable = mkEnableOption "Prysm client stats";
    package = mkOption {
      type = types.package;
      default = pkgs.prysm;
    };
    validator-metrics-url = mkOption {
      type = types.str;
      description = "The url of the validator instance";
      default = "127.0.0.1:8081/metrics";
    };
    beacon-node-metrics-url = mkOption {
      type = types.str;
      description = "The url of the beacon node instance";
      default = "127.0.0.1:8080/metrics";
    };
    api-url = mkOption {
      type = types.str;
      description = "The url of the client-stats api url";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.client-stats = let
      inherit (config.services.ethereum.consensus) prysm;
      dependent-services = (optional prysm.beacon-chain.enable "beacon-chain.service") ++ (optional prysm.validator.enable "validator.service");
    in {
      description = "Prysm client stats";
      enable = true;
      wantedBy = ["multi-user.target"];
      after = dependent-services;
      serviceConfig = {
        ExecStart = ''
          ${cfg.package}/bin/client-stats \
            --validator-metrics-url ${cfg.validator-metrics-url} \
            --beacon-node-metrics-url ${cfg.beacon-node-metrics-url} \
            --clientstats-api-url ${cfg.api-url}
        '';
        Restart = "always";
      };
      script = ''
        ${cfg.package}/bin/client-stats \
          --clientstats-api-url ${cfg.api-url} \
          ${optionalString prysm.beacon-chain.enable "--beacon-node-metrics-url ${cfg.beacon-node-metrics-url}"} \
          ${optionalString prysm.validator.enable "--validator-metrics-url ${cfg.validator-metrics-url}"} \
      '';
    };
  };
}
