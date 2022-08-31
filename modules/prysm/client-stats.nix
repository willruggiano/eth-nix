{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.prysm.client-stats;
in {
  options.services.prysm.client-stats = {
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
    systemd.user.services.client-stats = {
      description = "Prysm client stats";
      enable = true;
      wantedBy = ["default.target"];
      serviceConfig = {
        ExecStart = ''
          ${cfg.package}/bin/client-stats \
            --validator-metrics-url ${cfg.validator-metrics-url} \
            --beacon-node-metrics-url ${cfg.beacon-node-metrics-url} \
            --clientstats-api-url ${cfg.api-url}
        '';
        Restart = "always";
        RestartSec = 30;
      };
    };
  };
}
