{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.ethereum.consensus.prysm.beacon-chain;
in {
  options.services.ethereum.consensus.prysm.beacon-chain = {
    enable = mkEnableOption "Prysm beacon node";
    accept-terms-of-use = mkOption {
      type = types.bool;
      description = "Accept the terms of use";
      default = true;
    };
    checkpoint-sync = mkEnableOption "Enable the checkpoint sync feature";
    network = mkOption {
      type = with types; enum ["mainnet" "prater"];
      description = "The network to run on";
      default = "prater";
    };
    extra-arguments = mkOption {
      type = with types; listOf str;
      description = "Additional arguments to pass to prysm";
      default = [];
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      systemd.services.beacon-chain = let
        state-dir = "ethereum/${cfg.network}/consensus";
        checkpoint-sync-url =
          if cfg.network == "mainnet"
          then "https://sync.invis.tools"
          else "prater-sync.invis.tools";
        genesis-beacon-api-url =
          if cfg.network == "mainnet"
          then "https://sync.invis.tools"
          else "prater-sync.invis.tools";
      in {
        description = "Prysm beacon-chain node";
        enable = true;
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          DynamicUser = true;
          Restart = "always";
          StateDirectory = state-dir;
          # Hardening:
          PrivateTmp = true;
          ProtectSystem = "full";
          NoNewPrivileges = true;
          PrivateDevices = true;
          MemoryDenyWriteExecute = true;
        };
        script = concatStringsSep " " ([
            "${config.services.ethereum.consensus.prysm.package}/bin/beacon-chain"
            "--${cfg.network}"
            "--datadir /var/lib/${state-dir}"
            "--restore-target-dir /var/lib/${state-dir}"
          ]
          ++ cfg.extra-arguments
          ++ (optionals cfg.checkpoint-sync ["--checkpoint-sync-url=${checkpoint-sync-url}" "--genesis-beacon-api-url=${genesis-beacon-api-url}"])
          ++ (optional config.services.ethereum.jwt-secret.enable "--jwt-secret ${config.services.ethereum.jwt-secret.path}")
          ++ (optional cfg.accept-terms-of-use "--accept-terms-of-use"));
      };
    }
    (mkIf config.services.ethereum.execution.geth.enable {
      systemd.services.beacon-chain = {
        # TODO: Make this depend on whether geth is enabled.
        after = ["generate-jwt-secret.service" "geth.service"];
      };
    })
    (mkIf (!config.services.ethereum.execution.geth.enable) {
      systemd.services.beacon-chain = {
        # TODO: Make this depend on whether geth is enabled.
        after = ["network.target"];
        wants = ["geth.service"];
      };
    })
  ]);
}
