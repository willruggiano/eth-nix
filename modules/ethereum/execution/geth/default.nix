{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.ethereum.execution.geth;
in {
  options.services.ethereum.execution.geth = {
    enable = mkEnableOption "Enable geth as the ethereum execution client";
    package = mkOption {
      type = types.package;
      default = pkgs.go-ethereum.geth;
    };
    network = mkOption {
      type = types.enum ["mainnet" "goerli" "rinkeby" "ropsten" "yolov2"];
      description = "The network to connect to";
      default = "goerli";
    };
    extra-arguments = mkOption {
      type = with types; listOf str;
      description = "Additional arguments to pass to geth";
      default = [];
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      systemd.services.geth = let
        state-dir = "ethereum/${cfg.network}/execution";
      in {
        description = "Geth";
        enable = true;
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          DynamicUser = true;
          Restart = "always";
          StateDirectory = state-dir;
          # Hardening:
          PrivateTemp = true;
          ProtectSystem = "full";
          NoNewPrivileges = true;
          PrivateDevices = true;
          MemoryDenyWriteExecute = true;
        };
        script = concatStringsSep " " ([
            "${cfg.package}/bin/geth"
            "--nousb"
            "--${cfg.network}"
            "--datadir /var/lib/${state-dir}"
          ]
          ++ cfg.extra-arguments
          ++ (optional config.services.ethereum.jwt-secret.enable "--authrpc.jwtsecret ${config.services.ethereum.jwt-secret.path}"));
      };
    }
    (mkIf (config.services.ethereum.jwt-secret.enable && config.services.ethereum.jwt-secret.generate) {
      systemd.services.geth = {
        after = ["generate-jwt-secret.service" "network.target"];
        wants = ["generate-jwt-secret.service"];
      };
    })
  ]);
}
