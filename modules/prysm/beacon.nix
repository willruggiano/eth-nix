{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.prysm.beacon-chain;
in {
  options.services.prysm.beacon-chain = {
    enable = mkEnableOption "Prysm beacon node";
    package = mkOption {
      type = types.package;
      default = pkgs.prysm;
    };
    accept-terms-of-use = mkOption {
      type = types.bool;
      description = "Accept the terms of use";
      default = true;
    };
    network = mkOption {
      type = with types; enum ["mainnet" "prater" "pyrmont"];
      description = "The network to run on";
      default = "prater";
    };
    extra-arguments = mkOption {
      type = with types; listOf str;
      description = "Fallback execution node(s)";
      description = "Additional arguments to pass to prysm";
      default = [];
    };
  };

  config = mkIf cfg.enable {
    systemd.services.beacon-chain = {
      description = "Prysm beacon-chain node";
      enable = true;
      wantedBy = ["default.target"];
      # TODO: Make this depend on whether geth is enabled.
      after = ["geth-execution.service"];
      serviceConfig = {
        ExecStart = concatStringsSep " " ([
            "${cfg.package}/bin/beacon-chain"
            "--${cfg.network}"
          ]
          ++ cfg.extra-arguments
          ++ (optional cfg.accept-terms-of-use "--accept-terms-of-use"));
        Restart = "always";
        RestartSec = 30;
      };
    };
  };
}
