{ config, lib, pkgs, ... }:

with lib;
let cfg = config.services.geth;
in
{
  options = {
    services.geth = {
      enable = mkEnableOption "geth";
      network = mkOption {
        type = with types; enum [ "mainnet" "goerli" "rinkby" "ropsten" ];
        description = "The network to run on";
        default = "mainnet";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.geth = {
      description = "geth";
      enable = true;
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = ''
          ${pkgs.go-ethereum}/bin/geth \
            --http --http.addr 0.0.0.0 --http.vhosts=* --http.api web3,eth,net \
            --ws --ws.addr 0.0.0.0 --ws.api web3,eth,net \
            --syncmode light \
            --pcscdpath "" \
            --${cfg.network}
        '';
        Restart = "always";
        RestartSec = 30;
      };
    };
  };
}
