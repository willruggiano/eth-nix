{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.ethereum.consensus.prysm.validator;
in {
  options.services.ethereum.consensus.prysm.validator = {
    enable = mkEnableOption "Prysm validator";
    accept-terms-of-use = mkOption {
      type = types.bool;
      description = "Accept the terms of use";
      default = true;
    };
    network = mkOption {
      type = with types; enum ["mainnet" "prater"];
      description = "The network to run on";
      default = "prater";
    };
    wallet-password-file = mkOption {
      type = types.nullOr types.str;
      description = "Path to a plain-text, .txt file containing your wallet password";
      default = null;
    };
    extra-arguments = mkOption {
      type = with types; listOf str;
      description = "Additional arguments to pass to prysm";
      default = [];
    };
  };

  config = let
    state-dir = "ethereum/${cfg.network}/validator";
  in
    mkIf cfg.enable (mkMerge [
      {
        environment.systemPackages = [
          (pkgs.writeShellApplication {
            name = "validator-admin";
            runtimeInputs = [config.services.ethereum.consensus.prysm.package];
            text = concatStringsSep " " ([
                "validator --${cfg.network} --datadir /var/lib/${state-dir} --wallet-dir /var/lib/${state-dir}/prysm-wallet-v2"
              ]
              ++ (optional (cfg.wallet-password-file != null) "--wallet-password-file ${cfg.wallet-password-file}"));
          })
        ];

        systemd.services.validator = {
          description = "Prysm validator";
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
              "${config.services.ethereum.consensus.prysm.package}/bin/validator"
              "--${cfg.network}"
              "--datadir /var/lib/${state-dir}"
              "--wallet-dir /var/lib/${state-dir}/prysm-wallet-v2"
            ]
            ++ cfg.extra-arguments
            ++ (optional (cfg.wallet-password-file != null) "--wallet-password-file ${cfg.wallet-password-file}")
            ++ (optional cfg.accept-terms-of-use "--accept-terms-of-use"));
        };
      }
      (mkIf config.services.ethereum.consensus.prysm.beacon.enable {
        systemd.services.validator = {
          after = ["beacon-chain.service"];
          wants = ["beacon-chain.service"];
        };
      })
      (mkIf (!config.services.ethereum.consensus.prysm.beacon.enable) {
        systemd.services.validator = {
          after = ["network.target"];
        };
      })
    ]);
}
