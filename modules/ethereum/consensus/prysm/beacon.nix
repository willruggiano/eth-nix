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
    checkpoint-sync = {
      enable = mkEnableOption "Enable the checkpoint sync feature";
      url = mkOption {
        type = types.str;
        description = "URL of a synced beacon node to trust in obtaining checkpoint sync data";
      };
    };
    mev-relay-url = mkOption {
      type = types.str;
      description = "MEV builder relay http endpoint";
      default = "http://localhost:18550";
    };
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

  config = let
    state-dir = "ethereum/${cfg.network}/consensus";
  in
    mkIf cfg.enable (mkMerge [
      {
        environment.systemPackages = [
          (pkgs.writeShellApplication {
            name = "beacon-chain-admin";
            runtimeInputs = [config.services.ethereum.consensus.prysm.package];
            text = ''
              beacon-chain --${cfg.network} --datadir /var/lib/${state-dir} "$@"
            '';
          })
        ];

        systemd.services.beacon-chain = {
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
            ++ (optionals cfg.checkpoint-sync.enable ["--checkpoint-sync-url ${cfg.checkpoint-sync.url}" "--genesis-beacon-api-url ${cfg.checkpoint-sync.url}"])
            ++ (optional config.services.ethereum.jwt-secret.enable "--jwt-secret ${config.services.ethereum.jwt-secret.path}")
            ++ (optional config.services.ethereum.mev-boost.enable) "--http-mev-relay ${cfg.mev-relay-url}"
            ++ (optional cfg.accept-terms-of-use "--accept-terms-of-use"));
        };
      }
      (mkIf config.services.ethereum.execution.geth.enable (mkMerge [
        (mkIf config.services.ethereum.mev-boost.enable {
          systemd.services.beacon-chain = {
            after = ["generate-jwt-secret.service" "geth.service" "mev-boost.service" "network-online.target"];
            wants = ["generate-jwt-secret.service" "geth.service" "mev-boost.service"];
          };
        })
        (mkIf (!config.services.ethereum.mev-boost.enable) {
          systemd.services.beacon-chain = {
            after = ["generate-jwt-secret.service" "geth.service" "network-online.target"];
            wants = ["generate-jwt-secret.service" "geth.service"];
          };
        })
      ]))
      (mkIf (!config.services.ethereum.execution.geth.enable) (mkMerge [
        (mkIf config.services.ethereum.mev-boost.enable {
          systemd.services.beacon-chain = {
            after = ["mev-boost.service" "network-online.target"];
            wants = ["mev-boost.service"];
          };
        })
        (mkIf (!config.services.ethereum.mev-boost.enable) {
          systemd.services.beacon-chain = {
            after = ["network-online.target"];
          };
        })
      ]))
    ]);
}
