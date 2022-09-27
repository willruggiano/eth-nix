{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.prysm.validator;
in {
  options.services.prysm.validator = {
    enable = mkEnableOption "Prysm validator";
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

  config = mkIf cfg.enable (mkMerge [
    {
      systemd.services.validator = {
        description = "Prysm validator";
        enable = true;
        wantedBy = ["default.target"];
        serviceConfig = {
          ExecStart = concatStringsSep " " ([
              "${cfg.package}/bin/validator"
              "--${cfg.network}"
            ]
            ++ cfg.extra-arguments
            ++ (optional (cfg.wallet-password-file != null) "--wallet-password-file=${cfg.wallet-password-file}")
            ++ (optional cfg.accept-terms-of-use "--accept-terms-of-use"));
          Restart = "always";
          RestartSec = 30;
        };
      };
    }
    (mkIf config.services.prysm.beacon.enable {
      systemd.services.validator = {
        after = ["beacon-chain.service"];
        wants = ["beacon-chain.service"];
      };
    })
  ]);
}
