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
      default = "http://localhost:8081/metrics";
    };
    beacon-node-metrics-url = mkOption {
      type = types.str;
      description = "The url of the beacon node instance";
      default = "http://localhost:8080/metrics";
    };
    api-url = mkOption {
      type = types.str;
      description = "The url of the client-stats api url";
      default = null;
    };
    log-format = mkOption {
      type = types.enum ["text" "json" "fluentd" "journald"];
      description = "Specify log formatting";
      default = "journald";
    };
  };

  config = let
    inherit (config.services.ethereum.consensus) prysm;
    dependent-services = (optional prysm.beacon-chain.enable "beacon-chain.service") ++ (optional prysm.validator.enable "validator.service");
  in
    mkIf (cfg.enable && (prysm.beacon-chain.enable || prysm.validator.enable)) {
      systemd.services.client-stats = {
        description = "Prysm client stats";
        enable = true;
        wantedBy = ["multi-user.target"];
        after = dependent-services;
        serviceConfig = {
            DynamicUser = true;
            Restart = "always";
            # Hardening:
            PrivateTmp = true;
            ProtectSystem = "full";
            NoNewPrivileges = true;
            PrivateDevices = true;
            MemoryDenyWriteExecute = true;
        };
        script = ''
          ${cfg.package}/bin/client-stats \
            ${optionalString prysm.beacon-chain.enable "--beacon-node-metrics-url ${cfg.beacon-node-metrics-url}"} \
            ${optionalString prysm.validator.enable "--validator-metrics-url ${cfg.validator-metrics-url}"} \
            ${optionalString (cfg.api-url != null) "--clientstats-api-url ${cfg.api-url}"} \
            --log-format ${cfg.log-format}
        '';
      };
    };
}
