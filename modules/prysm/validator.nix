{ config, lib, pkgs, ... }:

with lib;
let cfg = services.prysm.beacon;
in
{
  options = {
    services.prysm.validator = {
      enable = mkEnableOption "Prysm validator";
      package = mkOption {
        type = types.package;
        default = pkgs.prysm;
      };
      network = mkOption {
        type = with types; enum [ "mainnet" "prater" "pyrmont" ];
        description = "The network to run on";
        default = "mainnet";
      };
      beacon-rpc-provider = mkOption {
        type = types.str;
        description = "Beacon node RPC provider endpoint";
        default = "127.0.0.1:4000";
      };
    };

    config = mkIf cfg.enable {
      systemd.user.services.validator = {
        description = "Prysm validator";
        enable = true;
        wantedBy = [ "default.target" ];
        serviceConfig = {
          ExecStart = ''
            ${cfg.package}/bin/validator \
              --web \
              --grpc-gateway-host 0.0.0.0 --monitoring-host 0.0.0.0 \
              --wallet-dir-password-file ~/.ethereum-wallet-password.txt \
              --beacon-rpc-provider ${cfg.beacon-rpc-provider} \
              --${cfg.network} \
              --accept-terms-of-use
          '';
          Restart = "always";
          RestartSec = 30;
        };
      };
    };
  }
